//
//  ZHViewController.h
//  GetM3u
//
//  Created by bejoy on 14/9/3.
//  Copyright (c) 2014年 zeng hui. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ZPlayer;

@interface ZHViewController : UIViewController<UIWebViewDelegate>
{
}

@property(nonatomic, retain)     UIWebView *webView;



- (instancetype)initWithPlayer:(ZPlayer *)player;

@property (nonatomic, readonly, strong) ZPlayer *player;


@end
