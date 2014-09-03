//
//  ZHViewController.m
//  GetM3u
//
//  Created by bejoy on 14/9/3.
//  Copyright (c) 2014年 zeng hui. All rights reserved.
//

#import "ZHViewController.h"

@interface ZHViewController ()

@end

@implementation ZHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    
    
    NSURL *url = [NSURL URLWithString:@"http://v.youku.com/v_show/id_XNzcyMDAxMzQw.html"];
    _webView.delegate = self;
    [_webView loadRequest:[NSURLRequest  requestWithURL:url  ]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *html =  [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];

    
    NSLog(@"%@", html);
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
    
    
}

@end
