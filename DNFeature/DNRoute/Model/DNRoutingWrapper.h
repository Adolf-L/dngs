/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNRoutingWrapper.h
 *
 * Description  : DNRoutingWrapper
 *
 * Author       : eisen
 *
 * History      : Creation, 2018/7/3, Create the file
 *****************************************************************************************
 **/

#import <Foundation/Foundation.h>
@class DNRouteModel;

typedef NS_ENUM(NSInteger, DNRoutingStatus) {
    DNRoutingStop,
    DNRoutingWorking,
    DNRoutingPaused,
};

@interface DNRoutingWrapper : NSObject

+ (DNRoutingWrapper *)sharedInstance;

- (void)startRouting:(DNRouteModel *)routeModel;

- (void)stopRouting:(NSString *)bundleID;

- (void)setPause:(BOOL)pause;

- (DNRoutingStatus)getRoutingStatus;

- (BOOL)isWorking;

@end
