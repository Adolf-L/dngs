//
//  AppDelegate.m
//  DNGPS
//
//  Created by eisen.chen on 2018/8/29.
//  Copyright © 2018年 eisen. All rights reserved.
//

#import "AppDelegate.h"
#import "WXApi.h"
#import "TalkingData.h"
#import "DNDefines.h"
#import "DNProfileManager.h"
#import "DNDrawerManager.h"
#import "DNRoutingWrapper.h"
#import <Bugly/Bugly.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <AVOSCloud/AVOSCloud.h>
#import <BMKLocationkit/BMKLocationAuth.h>
#import <BaiduMapAPI_Base/BMKMapManager.h>

@interface AppDelegate ()<BMKLocationAuthDelegate, BMKGeneralDelegate, TencentSessionDelegate, WXApiDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifdef DEBUG
    [AVCloud setProductionMode:NO];
#else
    [AVCloud setProductionMode:YES];
#endif
    [AVOSCloud setAllLogsEnabled:NO];
    [AVOSCloud setApplicationId:kLCAppID clientKey:kLCClientKey];
    [[DNProfileManager sharedInstance] downloadiOSProfile];
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = (UIViewController *)[DNDrawerManager sharedInstance].rootVC;
    [self.window makeKeyAndVisible];
    
    //百度地图定位
    [[BMKLocationAuth sharedInstance] checkPermisionWithKey:kBaiduMapKey authDelegate:self];
    //百度地图
    BMKMapManager *baiduMap = [[BMKMapManager alloc] init];
    BOOL ret = [baiduMap start:kBaiduMapKey generalDelegate:self];
    if (!ret) {
        NSLog(@"~# Baidu map register failed!");
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // TalkingData
        [TalkingData sessionStarted:kTalkingDataAppID withChannelId:kChannelId];
        
        // 注册微信sdk
        [WXApi registerApp:kWChatAppID];
        
        // 注册QQ
        if (![[TencentOAuth alloc] initWithAppId:kQQAppID andDelegate:self]) {
            NSLog(@"~# QQ register failed");
        }
        
        // 注册bugly
        BuglyConfig *config = [[BuglyConfig alloc] init];
        config.channel = @"AppStore";
        config.reportLogLevel = BuglyLogLevelWarn;
        [Bugly startWithAppId:kBuglyAppID config:config];
    });
    
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    if ([url.scheme rangeOfString:@"QQ"].location != NSNotFound) {
        return [TencentOAuth HandleOpenURL:url];
    } else {
        return [WXApi handleOpenURL:url delegate:self];
    }
    return YES;
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [AVOSCloud handleRemoteNotificationsWithDeviceToken:deviceToken];
}

#pragma mark - TencentSessionDelegate

- (void)tencentDidLogin
{
    
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    
}

- (void)tencentDidNotNetWork
{
    
}

@end
