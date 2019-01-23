/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNWebViewController.m
 *
 * Description  : DNWebViewController
 *
 * Author       : eisen
 *
 * History      : Creation, 2018/4/24, Create the file
 *****************************************************************************************
 **/

#import "DNWebViewController.h"
#import <WebKit/WebKit.h>

@interface DNWebViewController ()<WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, strong) NSDictionary *paramsDic;
@property (nonatomic, strong) WKWebView *webView;

@end

@implementation DNWebViewController

- (void)configWithParams:(NSDictionary *)params
{
    if (params) {
        self.paramsDic = params;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *title = [self.paramsDic valueForKey:@"Title"];
    if (title) {
        self.titleLabel.text = title;
    }
    NSString *urlStr = [self.paramsDic valueForKey:@"url"];
    if (urlStr) {
        NSURL *url = [NSURL URLWithString:urlStr];
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
}

- (WKWebView *)webView
{
    if (!_webView) {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        CGRect frame = CGRectMake(0, 64, screenSize.width, screenSize.height-64);
        _webView = [[WKWebView alloc] initWithFrame:frame];
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        [self.view addSubview:_webView];
    }
    return _webView;
}

@end
