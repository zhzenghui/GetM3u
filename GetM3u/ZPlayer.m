//
//  ZPlayer.m
//  GetM3u
//
//  Created by xy on 16/1/22.
//  Copyright © 2016年 zeng hui. All rights reserved.
//

#import "ZPlayer.h"
#import "ZFilePlayerResourceLoaderDelegate.h"
#import "NSObject+LSAdditions.h"



NSString * const kStatus                        = @"status";
NSString * const kRateKey                       = @"rate";
NSString * const kCurrentItemKey                = @"currentItem";
NSString * const kLoadedTimeRanges              = @"loadedTimeRanges";

NSString * const ZPlayerErrorDomain             = @"ZPlayerErrorDomain";
NSString * const ZFileScheme                    = @"customscheme";

@interface ZPlayer()< AVAssetResourceLoaderDelegate>

//@property (nonatomic,strong)YDSession *session;
@property (nonatomic,strong)NSURL *fileURL;

@property (nonatomic,strong)AVPlayer *player;

@property (nonatomic,strong)NSMutableDictionary *resourceLoaders;

@property (nonatomic,strong)id scrubberTimeObserver;
@property (nonatomic,strong)id clockTimeObserver;

@property (nonatomic,assign)BOOL pauseReasonForcePause;

@end



@implementation ZPlayer


+ (ZPlayer *)player {
    return [ZPlayer new];
}

- (void)fetchAndPlayFileAtURL:(NSURL *)fileURL {
    
    [self performBlockOnMainThreadSync:^{
        
        self.fileURL = fileURL;
        
        [self cancelAllAndClearPlayer];
        
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
        [asset.resourceLoader setDelegate:self queue:dispatch_get_main_queue()];
        
        AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
        [self addObserversForPlayerItem:item];
        
        [self createPlayerWithItem:item];
        
        [self notifyDidChangeCurrentItem];
        
        [self playAudioIfPossible];
    }];
    
}




- (instancetype)init{
    self = [super init];
    if(self){
        self.timeObservingPrecision = 0.0;
        self.resourceLoaders = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (void)cancelAllAndClearPlayer{
    [self clearPlayer];
    [self cancelAllResourceLoaders];
}
#pragma mark - Player Item

- (CMTime)playerItemDuration{
    AVPlayerItem *playerItem = [self.player currentItem];
    if (playerItem.status == AVPlayerItemStatusReadyToPlay){
        return([playerItem duration]);
    }
    return(kCMTimeInvalid);
}

- (double)playerItemAvailableDuration{
    NSArray *loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
    if ([loadedTimeRanges count] > 0) {
        CMTimeRange timeRange = [[loadedTimeRanges objectAtIndex:0] CMTimeRangeValue];
        double startSeconds = CMTimeGetSeconds(timeRange.start);
        double durationSeconds = CMTimeGetSeconds(timeRange.duration);
        return (startSeconds + durationSeconds);
    } else {
        return 0.0f;
    }
}



- (void)addObserversForPlayerItem:(AVPlayerItem *)item{
    if(item){
        [item addObserver:self
               forKeyPath:kStatus
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
        
        [item addObserver:self
               forKeyPath:kLoadedTimeRanges
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:item];
    }
}

- (void)removeObserversFromPlayerItem:(AVPlayerItem *)item{
    if(item){
        [item removeObserver:self forKeyPath:kStatus];
        [item removeObserver:self forKeyPath:kLoadedTimeRanges];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:item];
    }
}


- (void)addObserversForPlayer{
    if(self.player){
        [self.player addObserver:self
                      forKeyPath:kCurrentItemKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:NULL];
        [self.player addObserver:self
                      forKeyPath:kStatus
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:NULL];
        [self.player addObserver:self
                      forKeyPath:kRateKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:NULL];
    }
}

- (void)removeObserversFromPlayer{
    if(self.player){
        [self.player removeObserver:self forKeyPath:kCurrentItemKey];
        [self.player removeObserver:self forKeyPath:kRateKey];
        [self.player removeObserver:self forKeyPath:kStatus];
        [self removePlayerTimeObservers];
    }
}

- (void)addPlayerTimeObservers:(NSError **)error{
    
    [self removePlayerTimeObservers];
    
    double interval = .1f;
    
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration)){
        if(error){
            *error = [self errorWithCode:ZPlayerErrorCodeUnknown description:nil];
        }
        return;
    }
    double duration = CMTimeGetSeconds(playerDuration);
    if (CMTIME_IS_INDEFINITE(playerDuration) || duration <= 0) {
        if(error){
            *error = [self errorWithCode:ZPlayerErrorCodeUnknown description:nil];
        }
        [self syncPlayClock];
        return;
    }
    
    float precision = self.timeObservingPrecision;
    
    if(precision>0){
        interval = 0.5f * duration / precision;
    }
    
    __weak typeof(self) weakSelf = self;
    self.scrubberTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                                                                          queue:NULL
                                                                     usingBlock:^(CMTime time){
                                                                         [weakSelf syncScrubber];
                                                                     }];
    
    
    self.clockTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, NSEC_PER_SEC)
                                                                       queue:NULL
                                                                  usingBlock:^(CMTime time) {
                                                                      [weakSelf syncPlayClock];
                                                                  }];
}

- (void)syncScrubber{
//    [self notifyDidChangeScrubberTime];
}

- (void)syncPlayClock{
//    [self notifyDidChangeClockTime];
}

- (void)removePlayerTimeObservers{
    if (self.scrubberTimeObserver){
        [self.player removeTimeObserver:self.scrubberTimeObserver];
        self.scrubberTimeObserver = nil;
    }
    if (self.clockTimeObserver){
        [self.player removeTimeObserver:self.clockTimeObserver];
        self.clockTimeObserver = nil;
    }
}


#pragma mark - Key Value Observing

- (void)observeValueForKeyPath:(NSString*)path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context{
    
    if(object==self.player){
        if ([path isEqualToString:kRateKey]){
            float newRate = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
            BOOL willPlay = (newRate!= 0.f);
            if(willPlay){
                [self addPlayerTimeObservers:nil];
            }
            [self notifyDidChangeRate:newRate];
        }
        else if ([path isEqualToString:kCurrentItemKey]){
            
            AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
            AVPlayerItem *currentAVPlayerItem = newPlayerItem;
            
            if (newPlayerItem == (id)[NSNull null]){
                currentAVPlayerItem = nil;
                [self removePlayerTimeObservers];
            }
            
//            BOOL failed = (newPlayerItem != (id)[NSNull null] && newPlayerItem.status==AVPlayerStatusFailed);
//            [self currentAVPlayerItemDidChange:currentAVPlayerItem];
//            if(failed){
//                [self currentAVPlayerItemDidFailedWithError:currentAVPlayerItem.error];
//            }
        }
        else if ([path isEqualToString:kStatus]){
            if (self.player.status == AVPlayerStatusReadyToPlay) {
                [self notifyDidChangeReadyToPlayStatus:ZPlayerReadyToPlayPlayer];
                [self playAudioIfPossible];
            } else if (self.player.status == AVPlayerStatusFailed) {
                [self stop];
                [self notifyDidFailWithStatus:ZPlayerFailedPlayer error:self.player.error];
            }
        }
    }
    else if(object==self.player.currentItem){
        
        AVPlayerItem *currentPlayerItem = (AVPlayerItem *)object;
        
        if ([path isEqualToString:kStatus]){
            
            AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
            
            if(status==AVPlayerStatusReadyToPlay){
                [self addPlayerTimeObservers:nil];
                [self notifyDidChangeReadyToPlayStatus:ZPlayerReadyToPlayCurrentItem];
                [self playAudioIfPossible];
                
            }
            else if(status==AVPlayerStatusFailed){
                [self currentAVPlayerItemDidFailedWithError:currentPlayerItem.error];
            }
        }
        else if ([path isEqualToString:kLoadedTimeRanges]){
            NSArray *timeRanges = (NSArray *)[change objectForKey:NSKeyValueChangeNewKey];
            if (timeRanges && [timeRanges count]) {
                [self notifyDidPreLoadCurrentItemWithProgress:[self preloadProgress]];
            }
        }
    }
}



#pragma mark - Player Info

- (NSTimeInterval)duration{
    return CMTimeGetSeconds([self playerItemDuration]);
}

- (NSTimeInterval)currentTime{
    return CMTimeGetSeconds([self.player currentTime]);
}

- (BOOL)isPlaying{
    return self.player.rate != 0.f;
}

- (BOOL)isCurrentItemReadyToPlay{
    return (self.player.currentItem.status==AVPlayerItemStatusReadyToPlay);
}

- (float)rate{
    return self.player.rate;
}

- (float)preloadProgress{
    float progress = 0.0;
    if ([self.player currentItem].status == AVPlayerItemStatusReadyToPlay){
        float durationTime = CMTimeGetSeconds([self playerItemDuration]);
        float bufferTime = [self playerItemAvailableDuration];
        if(durationTime>0.0){
            progress = bufferTime/durationTime;
        }
    }
    return progress;
}

- (ZPlayerStatus)status{
    if ([self isPlaying]){
        return ZPlayerStatusPlaying;
    }
    else if (self.pauseReasonForcePause){
        return ZPlayerStatusPause;
    }
    else{
        return ZPlayerStatusUnknown;
    }
}


#pragma mark - Player State Changing

- (void)play{
    [self performBlockOnMainThreadSync:^{
        if([self isPlaying]==NO){
            self.pauseReasonForcePause = NO;
            [self playAudio];
        }
    }];
}

- (void)pause{
    [self performBlockOnMainThreadSync:^{
        if([self isPlaying]){
            self.pauseReasonForcePause = YES;
            [self pauseAudio];
        }
    }];
}

- (void)stop{
    [self performBlockOnMainThreadSync:^{
        self.pauseReasonForcePause = YES;
        if([self isPlaying]){
            [self stopVideo];
        }
        [self cancelAllAndClearPlayer];
    }];
}

- (void)seekToTime:(NSTimeInterval)time{
    [self performBlockOnMainThreadSync:^{
        @try{[self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];}@catch (NSException *exc) {}
    }];
}


- (void)playAudio{
    self.player.rate = 1.0;
}

- (void)playAudioIfPossible{
    if (self.isPlaying==NO && self.pauseReasonForcePause==NO){
        [self playAudio];
    }
}

- (void)pauseAudio{
    [self.player pause];
}

- (void)stopVideo{
    [self.player pause];
}


#pragma mark - Player Create/Destroy

- (void)createPlayerWithItem:(AVPlayerItem *)playerItem{
    self.player = [AVPlayer playerWithPlayerItem:playerItem];

    [self addObserversForPlayer];
}

- (void)clearPlayer{
    [self stopVideo];
    [self removeObserversFromPlayer];
    [self removeObserversFromPlayerItem:self.player.currentItem];
    self.player = nil;
    self.pauseReasonForcePause = NO;
}



#pragma mark - Player Items Switching


- (void)currentAVPlayerItemDidFailedWithError:(NSError *)error{
    [self notifyDidFailWithStatus:ZPlayerFailedCurrentItem error:error];
    [self stop];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification{
    [self playerDidReachEnd];
}

- (void)playerDidReachEnd{
    self.fileURL = nil;
    [self stop];
    [self notifyDidReachEnd];
}

- (void)currentAVPlayerItemDidChange:(AVPlayerItem *)playerItem{
    [self notifyDidChangeCurrentItem];
}


#pragma mark - Call Back`s

- (void)notifyDidFailWithStatus:(NSInteger)status error:(NSError *)error{
    [self performBlockOnMainThreadSync:^{
        if([self.delegate respondsToSelector:@selector(player:didFailWithStatus:error:)]){
            [self.delegate player:self didFailWithStatus:status error:error];
        }
    }];
}

- (void)notifyDidChangeReadyToPlayStatus:(NSInteger)status{
    [self performBlockOnMainThreadSync:^{
        if([self.delegate respondsToSelector:@selector(player:didChangeReadyToPlayStatus:)]){
            [self.delegate player:self didChangeReadyToPlayStatus:status];
        }
    }];
}

- (void)notifyDidChangeRate:(float)rate{
    [self performBlockOnMainThreadSync:^{
        if([self.delegate respondsToSelector:@selector(player:didChangeRate:)]){
            [self.delegate player:self didChangeRate:rate];
        }
    }];
}

- (void)notifyDidPreLoadCurrentItemWithProgress:(float)progress{
    [self performBlockOnMainThreadSync:^{
        if([self.delegate respondsToSelector:@selector(player:didPreLoadCurrentItemWithProgress:)]){
            [self.delegate player:self didPreLoadCurrentItemWithProgress:progress];
        }
    }];
}

- (void)notifyDidChangeCurrentItem{
    [self performBlockOnMainThreadSync:^{
        if([self.delegate respondsToSelector:@selector(playerDidChangeCurrentItem:)]){
            [self.delegate playerDidChangeCurrentItem:self];
        }
    }];
}

- (void)notifyDidReachEnd{
    [self performBlockOnMainThreadSync:^{
        if([self.delegate respondsToSelector:@selector(playerDidReachEnd:)]){
            [self.delegate playerDidReachEnd:self];
        }
    }];
}

- (void)notifyDidChangeScrubberTime{
    [self performBlockOnMainThreadSync:^{
        if([self.delegate respondsToSelector:@selector(playerDidChangeScrubberTime:)]){
            [self.delegate playerDidChangeScrubberTime:self];
        }
    }];
}

- (void)notifyDidChangeClockTime{
    [self performBlockOnMainThreadSync:^{
        if([self.delegate respondsToSelector:@selector(playerDidChangeClockTime:)]){
            [self.delegate playerDidChangeClockTime:self];
        }
    }];
}

#pragma mark - Errors

- (NSError *)errorWithCode:(ZPlayerErrorCode)code description:(NSString *)errorDescription{
    NSMutableDictionary *errorDict = [NSMutableDictionary dictionary];
    if(errorDescription){
        [errorDict setObject:errorDescription forKey:NSLocalizedDescriptionKey];
    }
    NSError *error = [NSError errorWithDomain:ZPlayerErrorDomain code:code userInfo:errorDict];
    return error;
}

- (NSError *)errorWithCode:(ZPlayerErrorCode)code{
    return [self errorWithCode:code description:nil];
}



- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest{
    NSURL *resourceURL = [loadingRequest.request URL];
    if([resourceURL.scheme isEqualToString:ZFileScheme]){
        //        LSFilePlayerResourceLoader *loader = [self resourceLoaderForRequest:loadingRequest];
        //        if(loader==nil){
        //            loader = [[LSFilePlayerResourceLoader alloc] initWithResourceURL:resourceURL session:self.session];
        //            loader.delegate = self;
        //            [self.resourceLoaders setObject:loader forKey:[self keyForResourceLoaderWithURL:resourceURL]];
        //        }
        //        [loader addRequest:loadingRequest];
        return YES;
    }
    return NO;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
    //    LSFilePlayerResourceLoader *loader = [self resourceLoaderForRequest:loadingRequest];
    //    [loader removeRequest:loadingRequest];
}



#pragma mark - LSFilePlayerResourceLoader

- (void)removeResourceLoader:(ZFilePlayerResourceLoader *)resourceLoader{
    id <NSCopying> requestKey = [self keyForResourceLoaderWithURL:resourceLoader.resourceURL];
    if(requestKey){
        [self.resourceLoaders removeObjectForKey:requestKey];
    }
}

- (void)cancelAndRemoveResourceLoaderForURL:(NSURL *)resourceURL{
    id <NSCopying> requestKey = [self keyForResourceLoaderWithURL:resourceURL];
    ZFilePlayerResourceLoader *loader = [self.resourceLoaders objectForKey:requestKey];
    [self removeResourceLoader:loader];
    [loader cancel];
}

- (void)cancelAllResourceLoaders{
    NSArray *items = [self.resourceLoaders allValues];
    [self.resourceLoaders removeAllObjects];
    for(ZFilePlayerResourceLoader *loader in items){
        [loader cancel];
    }
}

- (id<NSCopying>)keyForResourceLoaderWithURL:(NSURL *)requestURL{
    if([requestURL.scheme isEqualToString:ZFileScheme]){
        NSString *s = requestURL.absoluteString;
        return s;
    }
    return nil;
}

- (ZFilePlayerResourceLoader *)resourceLoaderForRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
    NSURL *interceptedURL = [loadingRequest.request URL];
    if([interceptedURL.scheme isEqualToString:ZFileScheme]){
        id <NSCopying> requestKey = [self keyForResourceLoaderWithURL:[loadingRequest.request URL]];
        ZFilePlayerResourceLoader *loader = [self.resourceLoaders objectForKey:requestKey];
        return loader;
    }
    return nil;
}

- (void)filePlayerResourceLoader:(ZFilePlayerResourceLoader *)resourceLoader didFailWithError:(NSError *)error{
    [self cancelAndRemoveResourceLoaderForURL:resourceLoader.resourceURL];
}


@end
