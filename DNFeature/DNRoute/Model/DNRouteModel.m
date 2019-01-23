//
/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNRouteModel.m
 *
 * Description  : DNRouteModel
 *
 * Author       : eisen
 *
 * History      : Creation, 2017/4/23, Create the file
 *****************************************************************************************
 **/

#import "DNRouteModel.h"

@implementation DNRouteModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _bundleID  = @"com.deniu.Daniu";
        _status    = CurStatus_Close;
        _waitTime  = 5.0;
        _mapType   = MapType_Baidu;
        _routeType = DNRouteTypeCar;
        _gpsRule   = GPSRule_Time;
        _routeRule = RouteRule_Stay;
        _toastType = ToastType_None;
        _speedList = @{[NSString stringWithFormat:@"%ld", (long)DNRouteTypeWalk]: @(15),
                       [NSString stringWithFormat:@"%ld", (long)DNRouteTypeRide]: @(20),
                       [NSString stringWithFormat:@"%ld", (long)DNRouteTypeCar]: @(50),
                       [NSString stringWithFormat:@"%ld", (long)DNRouteTypeLine]: @(80)};
    }
    return self;
}

- (NSString*)obtainRouteType
{
    if (self.routeType == DNRouteTypeWalk) {
        return @"步行";
    } else if (self.routeType == DNRouteTypeRide) {
        return @"骑行";
    } else if (self.routeType == DNRouteTypeCar) {
        return @"驾车";
    } else {
        return @"直线";
    }
}

- (NSString*)obtainRouteRule
{
    if (self.routeRule == RouteRule_Stay) {
        return @"终点停留";
    } else if (self.routeRule == RouteRule_Circle) {
        return @"往返循环";
    } else {
        return @"终止模拟";
    }
}

- (NSString *)ontatinRulePrompt
{
    if (self.routeRule == RouteRule_Stay) {
        return @"到达终点后，在终点保持停留";
    } else if (self.routeRule == RouteRule_Circle) {
        return @"到达终点后，以ABC-CBA的模式循环";
    } else {
        return @"到达终点后，停止路线模拟，回到真实位置";
    }
}

- (BMKDrivingPolicy)obtainDrivingPolicy
{
    if (self.gpsRule == GPSRule_Distance) {
        return BMK_DRIVING_DIS_FIRST;
    } else if (self.gpsRule == GPSRule_Traffic) {
        return BMK_DRIVING_BLK_FIRST;
    } else {
        return BMK_DRIVING_TIME_FIRST;
    }
}

- (NSArray *)keyPoints
{
    if ([_keyPoints isKindOfClass:[NSArray class]] &&
        _keyPoints.count > 0 &&
        [_keyPoints[0] isKindOfClass:[NSString class]]) {
        NSMutableArray *pointArray = [NSMutableArray array];
        [_keyPoints enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *pathDic = (NSDictionary *)obj;
            if ([obj isKindOfClass:[NSString class]]) {
                pathDic = [NSDictionary dictionaryWithJsonString:obj];
            }
            [pointArray addObject:pathDic];
        }];
        _keyPoints = pointArray;
    }
    return _keyPoints;
}

@end
