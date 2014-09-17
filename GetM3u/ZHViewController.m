//
//  ZHViewController.m
//  GetM3u
//
//  Created by bejoy on 14/9/3.
//  Copyright (c) 2014年 zeng hui. All rights reserved.
//

#import "ZHViewController.h"
#import "AFNetworking/AFNetworking.h"

@interface ZHViewController ()

@end

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

- (void)viewDidLoad
{
    [super viewDidLoad];

//    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
//    
//    
//    NSURL *url = [NSURL URLWithString:@"http://v.youku.com/v_show/id_XNzcyMDAxMzQw.html"];
//    _webView.delegate = self;
//    [_webView loadRequest:[NSURLRequest  requestWithURL:url  ]];
//    
    
    
    [self gethtmlM3u8];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
    NSLog(@"%@",      webView.request);
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
//    NSString *html =  [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];

    

           NSString *str = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('video')[0].getAttribute('src');"];
    
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

NSLog(@"Web获取视频地址信息=======%@",str);



}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
    
    
}

@end
