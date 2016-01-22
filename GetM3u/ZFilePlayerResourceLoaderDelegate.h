//
//  ZFilePlayerResourceLoaderDelegate.h
//  GetM3u
//
//  Created by xy on 16/1/22.
//  Copyright © 2016年 zeng hui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface ZFilePlayerResourceLoaderDelegate : NSObject

@end


//@class YDSession;
@protocol ZFilePlayerResourceLoaderDelegate;


@interface ZFilePlayerResourceLoader : NSObject

@property (nonatomic,readonly,strong)NSURL *resourceURL;

@property (nonatomic,readonly)NSArray *requests;

//@property (nonatomic,readonly,strong)YDSession *session;

@property (nonatomic,readonly,assign)BOOL isCancelled;

@property (nonatomic,weak)id<ZFilePlayerResourceLoaderDelegate> delegate;


//- (instancetype)initWithResourceURL:(NSURL *)url session:(YDSession *)session;

- (void)addRequest:(AVAssetResourceLoadingRequest *)loadingRequest;

- (void)removeRequest:(AVAssetResourceLoadingRequest *)loadingRequest;

- (void)cancel;

@end



@protocol ZFilePlayerResourceLoaderDelegate <NSObject>

@optional

- (void)filePlayerResourceLoader:(ZFilePlayerResourceLoader *)resourceLoader didFailWithError:(NSError *)error;

- (void)filePlayerResourceLoader:(ZFilePlayerResourceLoader *)resourceLoader didLoadResource:(NSURL *)resourceURL;

@end
