//
//  ZPlayer.h
//  GetM3u
//
//  Created by xy on 16/1/22.
//  Copyright © 2016年 zeng hui. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>


typedef enum {
    ZPlayerStatusUnknown = -1,
    ZPlayerStatusPlaying,
    ZPlayerStatusPause,
} ZPlayerStatus;

typedef enum {
    ZPlayerErrorCodeUnknown=-1,
} ZPlayerErrorCode;

typedef NS_ENUM(NSUInteger, ZPlayerReadyToPlayStatus) {
    ZPlayerReadyToPlayPlayer = 200,
    ZPlayerReadyToPlayCurrentItem,
};

typedef NS_ENUM(NSUInteger, ZPlayerFailedStatus) {
    ZPlayerFailedPlayer = 500,
    ZPlayerFailedCurrentItem,
};

NSString * const kStatus                        = @"status";
NSString * const kRateKey                       = @"rate";
NSString * const kCurrentItemKey                = @"currentItem";
NSString * const kLoadedTimeRanges              = @"loadedTimeRanges";

NSString * const ZPlayerErrorDomain             = @"ZPlayerErrorDomain";

NSString * const ZFileScheme                    = @"customscheme";

@protocol ZPlayerDelegate;

@interface ZPlayer : NSObject



@property (nonatomic,assign)float timeObservingPrecision;
@property (nonatomic,weak)id<ZPlayerDelegate>delegate;



+ (ZPlayer *)player;

@end
//@protocol ZPlayerDelegate <NSObject>
//
//- (void)player:(ZPlayer *)player didFailWithStatus:(ZPlayerFailedStatus)status error:(NSError *)error;
//- (void)player:(ZPlayer*)player didChangeReadyToPlayStatus:(ZPlayerReadyToPlayStatus)status;
//
//- (void)player:(ZPlayer*)player didChangeRate:(float)rate;
//
//- (void)player:(ZPlayer*)player didPreLoadCurrentItemWithProgress:(float)progress;
//- (void)playerDidChangeCurrentItem:(ZPlayer*)player;
//- (void)playerDidReachEnd:(ZPlayer*)player;
//
//- (void)playerDidChangeScrubberTime:(ZPlayer*)player;
//- (void)playerDidChangeClockTime:(ZPlayer*)player;
//
//@end