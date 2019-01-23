/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNRouteManager.h
 *
 * Description  : DNRouteManager
 *
 * Author       : eisen
 *
 * History      : Creation, 2018/3/28, Create the file
 *****************************************************************************************
 **/

#import <Foundation/Foundation.h>

@interface DNRouteManager : NSObject

@property (nonatomic, weak, readonly) UINavigationController *rootNVC;

+ (DNRouteManager *)sharedInstance;

// 设置RootNVC
- (void)setRootNaviViewController:(UINavigationController*)rootNVC;

// 注册默认Routes
- (void)registerDefaultRoutes;

// 跳转 String
- (BOOL)routeURLStr:(NSString *)urlStr;

// 跳转 String
- (BOOL)routeURLStr:(NSString *)urlStr withParamsDic:(NSDictionary<NSString *, id> *)paramsDic;

- (void)gotoWebsite:(NSString *)url;

@end
