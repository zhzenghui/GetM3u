//
//  ZHViewController.m
//  GetM3u
//
//  Created by bejoy on 14/9/3.
//  Copyright (c) 2014年 zeng hui. All rights reserved.
//

#import "ZHViewController.h"
#import "AFNetworking/AFNetworking.h"
#import <AVFoundation/AVFoundation.h>

#import "ZPlayer.h"


@interface ZHViewController () {
    
//    ZPlayerView *videoPlayer;
    NSString *moviePath;
    

}

@property(nonatomic, strong) ZPlayer *player;
@property(nonatomic, strong) AVAssetExportSession *exportSession;
@property(nonatomic, strong) NSString  *tmpVideoPath;

- (NSURL*)URL;

@end




static void *AVPlayerDemoPlaybackViewControllerRateObservationContext = &AVPlayerDemoPlaybackViewControllerRateObservationContext;
static void *AVPlayerDemoPlaybackViewControllerStatusObservationContext = &AVPlayerDemoPlaybackViewControllerStatusObservationContext;
static void *AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext = &AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext;
@implementation ZHViewController

- (void)gethtmlM3u8
{
    NSURL *url = [NSURL URLWithString:@"http://v.youku.com/v_show/id_XNzcyMDAxMzQw.html"];

    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
//    operation.responseSerializer = [AFXMLParserResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

//        NSString *str = [NSString stringWithCString:responseObject  encoding:<#(NSStringEncoding)#>]
        
        
        NSString* newStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"%@", newStr);

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
    [operation start];
    

    
}


//
//- (instancetype)initWithPlayer:(ZPlayer *)player{
//    self = [super init];
//    if(self){
//        self.player = player;
//        self.player.delegate = self;
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    _webView.backgroundColor = [UIColor orangeColor];
    
    NSURL *url = [NSURL URLWithString:@"http://v.youku.com/v_show/id_XOTIwMTgwNTYw.html"];
//    url = [NSURL URLWithString:@"http://pan.baidu.com/share/link?shareid=3589523377&uk=56589384&fid=856793824053437"];
//    http://v.pptv.com/show/J6Mwrxd97SuODHQ.html
    
    url = [NSURL URLWithString:@"http://v.pptv.com/show/J6Mwrxd97SuODHQ.html"];
    _webView.delegate = self;
    [_webView loadRequest:[NSURLRequest  requestWithURL:url  ]];
//
    
    [self.view addSubview:_webView];
//    [self gethtmlM3u8];
    
    
     // 今回はすでにDocuments以下に置いてある動画を再生する
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *directory = [paths objectAtIndex:0];
//    moviePath = [directory stringByAppendingPathComponent:@"/movie.mov"];
//    
//    NSURL *url =
//    
//    
//    NSURL *movieURL =  [NSURL URLWithString:@"http://pl.youku.com/playlist/m3u8?vid=340302095&type=mp4&ts=1453427391&keyframe=0&ep=dCaRGU2PUc0J5STdgD8bby3rdiYKXP0O9hyFg9JrBdQmQey7&sid=6453427390728128192a5&token=2944&ctype=12&ev=1&oip=1981419708"];
//    
//    NSString *s = [NSString stringWithFormat: @"%@://v.cdn.vine.co/r/videos/BA059548A51258987840487243776_4d6caa19305.1.0.12936937827581777625.mp4", ZFileScheme];
//    s = @"http://v.cdn.vine.co/r/videos/BA059548A51258987840487243776_4d6caa19305.1.0.12936937827581777625.mp4";
//    movieURL =  [NSURL URLWithString:s];;
//
//    
//    
////    AVAsset *asset = [AVAsset assetWithURL:movieURL];
////    AVPlayerItem *item = [[AVPlayerItem alloc] initWithAsset:asset];
//
//    self.player = [[ZPlayer alloc] init];
//
//    [self.player fetchAndPlayFileAtURL:movieURL ];
//
//    
//    
//    
//    //
////    
////    _player = [[AVPlayer alloc] initWithPlayerItem:item];
////
////    ZPlayerView *pv = [[ZPlayerView alloc] init];
//////    [pv setPlayer:_player];
//////    
////    AVPlayerLayer *playLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
//////    pv.frame = self.view.frame;
//////
//    UIView *pv = [[UIView alloc] initWithFrame:self.view.frame];
////    pv.backgroundColor = [UIColor blackColor];
////    [pv.layer addSublayer:playLayer];
////
////    
//    [self.view addSubview:pv];
////
//    [self.player play];
//    
//    
//    return;
//    
//    
////    AVAssetExportSession *es = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetLowQuality];
////    
//    NSString *outPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"out.mp4"];
//    
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    [fileManager removeItemAtPath:outPath error:NULL];
//    
//    
//    self.tmpVideoPath = outPath;
////
////    es.outputFileType = @"com.apple.quicktime-movie";
////    es.outputURL = [[NSURL alloc] initFileURLWithPath:outPath];
////    NSLog(@"exporting to %@",outPath);
////    [es exportAsynchronouslyWithCompletionHandler:^{
////        NSString *status = @"";
////        
////        if( es.status == AVAssetExportSessionStatusUnknown ) status = @"AVAssetExportSessionStatusUnknown";
////        else if( es.status == AVAssetExportSessionStatusWaiting ) status = @"AVAssetExportSessionStatusWaiting";
////        else if( es.status == AVAssetExportSessionStatusExporting ) status = @"AVAssetExportSessionStatusExporting";
////        else if( es.status == AVAssetExportSessionStatusCompleted ) status = @"AVAssetExportSessionStatusCompleted";
////        else if( es.status == AVAssetExportSessionStatusFailed ) status = @"AVAssetExportSessionStatusFailed";
////        else if( es.status == AVAssetExportSessionStatusCancelled ) status = @"AVAssetExportSessionStatusCancelled";
////        
////        NSLog(@"done exporting to %@ status %d = %@ (%@)",outPath,es.status, status,[[es error] localizedDescription]);
////    }];
//
//   
//
//    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:movieURL options:nil];
//    AVMutableComposition* mixComposition = [AVMutableComposition composition];
//    
//    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
//    AVAssetTrack *clipVideoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
//    AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
//    AVAssetTrack *clipAudioTrack = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
//    //If you need audio as well add the Asset Track for audio here
//    
//    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:clipVideoTrack atTime:kCMTimeZero error:nil];
//    [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:clipAudioTrack atTime:kCMTimeZero error:nil];
//    
//    [compositionVideoTrack setPreferredTransform:[[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] preferredTransform]];
//    
//    CGSize sizeOfVideo=[[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize];
//    
//    //TextLayer defines the text they want to add in Video
//    //Text of watermark
//    CATextLayer *textOfvideo=[[CATextLayer alloc] init];
//    textOfvideo.string=[NSString stringWithFormat:@"Add Text"];//text is shows the text that you want add in video.
//    textOfvideo.fontSize = 18;//fontUsed is the name of font
//    [textOfvideo setFrame:CGRectMake(0, 0, sizeOfVideo.width, sizeOfVideo.height/6)];
//    [textOfvideo setAlignmentMode:kCAAlignmentCenter];
//    [textOfvideo setForegroundColor:[[UIColor blueColor] CGColor]];
//    
//    //Image of watermark
//    UIImage *myImage=[UIImage imageNamed:@"pic.jpg"];
//    CALayer *layerCa = [CALayer layer];
//    layerCa.contents = (id)myImage.CGImage;
//    layerCa.frame = CGRectMake(0, 0, sizeOfVideo.width, sizeOfVideo.height);
//    layerCa.opacity = 1.0;
//    
//    CALayer *optionalLayer=[CALayer layer];
//    [optionalLayer addSublayer:textOfvideo];
//    optionalLayer.frame=CGRectMake(0, 0, sizeOfVideo.width, sizeOfVideo.height);
//    [optionalLayer setMasksToBounds:YES];
//    
//    CALayer *parentLayer=[CALayer layer];
//    CALayer *videoLayer=[CALayer layer];
//    parentLayer.frame=CGRectMake(0, 0, sizeOfVideo.width, sizeOfVideo.height);
//    videoLayer.frame=CGRectMake(0, 0, sizeOfVideo.width, sizeOfVideo.height);
//    [parentLayer addSublayer:videoLayer];
//    [parentLayer addSublayer:optionalLayer];
//    [parentLayer addSublayer:layerCa];
//    
//    AVMutableVideoComposition *videoComposition=[AVMutableVideoComposition videoComposition] ;
//    videoComposition.frameDuration=CMTimeMake(1, 30);
//    videoComposition.renderSize=sizeOfVideo;
//    videoComposition.animationTool=[AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
//    
//    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
//    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [mixComposition duration]);
//    AVAssetTrack *videoTrack = [[mixComposition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
//    AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
//    instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
//    videoComposition.instructions = [NSArray arrayWithObject: instruction];
//    
//    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
//    NSString *destinationPath = [documentsDirectory stringByAppendingFormat:@"/utput_%@.mov", [dateFormatter stringFromDate:[NSDate date]]];
//    
//    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
//    exportSession.videoComposition=videoComposition;
//    
//    exportSession.outputURL = [NSURL fileURLWithPath:destinationPath];
//    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
//    [exportSession exportAsynchronouslyWithCompletionHandler:^{
//        switch (exportSession.status)
//        {
//            case AVAssetExportSessionStatusCompleted:
//                NSLog(@"Export OK");
////                if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(destinationPath)) {
////                    UISaveVideoAtPathToSavedPhotosAlbum(destinationPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
////                }
//                break;
//            case AVAssetExportSessionStatusFailed:
//                NSLog (@"AVAssetExportSessionStatusFailed: %@", exportSession.error);
//                break;
//            case AVAssetExportSessionStatusCancelled:
//                NSLog(@"Export Cancelled");
//                break;
//        }
//    }];
//
//
    
    
    
}


//video:didFinishSavingWithError:contextInfo:

- (void)video:(id)video didFinishSavingWithError:(NSError *)error contextInfo:(id)contextInfo {
    
    NSLog(@"didFinishSavingWithError");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType; {
    
    NSLog(@"start :  %@", request.URL.absoluteString   );
    return YES;
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
//    NSLog(@"%@",      webView.request);
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
//  jxxx
    
    
    NSString *lJs = @"document.documentElement.innerHTML";
    NSString *lHtml1 = [webView stringByEvaluatingJavaScriptFromString:lJs];
//    NSLog(@"html内容:%lu",(unsigned long)lHtml1.length);
    
    // NSString *lJs2 = @"(document.getElementsByTagName(\"video\")[0]).getElementsByTagName(\"source\")[0].src";  //qiyi
    NSString *lJs2 = @"(document.getElementsByTagName(\"video\")[0]).src";// youku,tudou,ku6 ,souhu
    NSString *lm3u8 = [webView stringByEvaluatingJavaScriptFromString:lJs2];
    NSLog(@"video source:%@",lm3u8);
    
    

//           NSString *str = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('video')[0].getAttribute('src');"];
    
//    if (![str isEqualToString:@""])
//    {
//          
////                         NSString *tempStr =str;
////                         //NSLog(@"======%@",tempStr);
////                        NSRange range = [ str rangeOfString:@"http://"];
////                         if (range.length==0){
////                                range = [videolinkStr rangeOfString:@"youku.com"];
////                                if (range.length>0){
////                                        str = [@"http://v.youku.com" stringByAppendingString:tempStr];
////                                    }
////                             }
//        
//    
//     
//    }
//else{
//                   BOOL sourcemode = [self isSourceMode];
//                    if (sourcemode){
//                           str = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('source')[0].getAttribute('src')"];
//                        }
//                }
//         if (IfPass == NO) {//设置BOOL类型的IfPass主要目的避免重复加载获取。
//      
//               if (str && ![str isEqualToString:@""]) {
//                        [webView stopLoading];
//                        if ([delegate respondsToSelector:@selector(authorizeWebView:didReceiveAuthorizeCode:)])
//                         {
//                                  NSLog(@"地址信息=======%@",str);
//                                  IfPass = YES;
//                                 [delegate authorizeWebView:self didReceiveAuthorizeCode:str];
//                              }
//                   }
//           }else if (IfPass == YES){
//                     [webView stopLoading];
//                     //NSLog(@"地址信息=======%@",str);
//              }

//NSLog(@"Web获取视频地址信息=======%@",str);



}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSURLRequest *r =webView.request;
    
    
//    NSLog(@"url : %@", r.URL.absoluteString);
    
    
    
}


#pragma mark - AVAssetResourceLoaderDelegate



@end
