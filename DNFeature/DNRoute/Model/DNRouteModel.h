/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNRouteModel.h
 *
 * Description  : DNRouteModel
 *
 * Author       : eisen
 *
 * History      : Creation, 2017/4/23, Create the file
 *****************************************************************************************
 **/

#import <UIKit/UIKit.h>
#import "DNDefines.h"
#import "BMKSearchComponent.h"
#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(int, DefaultSpeed) {
    DefaultSpeedWalk  = 15,
    DefaultSpeedRide  = 20,
    DefaultSpeedDrive = 50,
    DefaultSpeedLine  = 80,
};

typedef NS_ENUM(NSInteger, DNRouteType) {
    DNRouteTypeWalk = 1,
    DNRouteTypeRide = 2,
    DNRouteTypeCar  = 3,
    DNRouteTypeLine = 4,
};

typedef NS_ENUM(NSInteger, CurStatus) {
    CurStatus_Close,
    CurStatus_Open,
    CurStatus_Working,
};
typedef NS_ENUM(NSInteger, MapType) {
    MapType_Baidu,        //百度地图
    MapType_Gaode,        //高德地图
    MapType_Tencent,      //腾讯地图
};
typedef NS_ENUM(NSInteger, RouteType) {
    RouteType_Walk=100,   //步行
    RouteType_Car,        //驾车
    RouteType_Direct,     //直线
};
typedef NS_ENUM(NSInteger, RouteRule) {
    RouteRule_Stay=200,   //停留
    RouteRule_Circle,     //循环
    RouteRule_Stop,       //终止
};
typedef NS_ENUM(NSInteger, GPSRule) {
    GPSRule_Time=300,     //时间短
    GPSRule_Traffic,      //躲避拥堵
    GPSRule_Distance,     //路程短
};
typedef NS_ENUM(NSInteger, ToastType) {
    ToastType_None   = 0,      //没有提醒
    ToastType_Node   = 1 << 0, //节点提醒
    ToastType_Finish = 1 << 1, //终点提醒
};

@interface DNRouteModel : NSObject

@property (nonatomic, strong) NSString*     bundleID;   //bundleID
@property (nonatomic, assign) CurStatus     status;     //模拟路线状态
@property (nonatomic, assign) MapType       mapType;    //地图类型
@property (nonatomic, assign) DNRouteType   routeType;  //模式：步行、骑行、驾车、直线
@property (nonatomic, strong) NSDictionary  *speedList; //速度列表
@property (nonatomic, assign) int           waitTime;   //红灯等待时间
@property (nonatomic, assign) RouteRule     routeRule;  //到达终点后：停留、循环、终止
@property (nonatomic, assign) GPSRule       gpsRule;    //规划方式：路程短、躲避拥堵、时间短
@property (nonatomic, assign) ToastType     toastType;  //提示音
@property (nonatomic, strong) NSArray       *keyPoints; //路线的关键节点(存放数组)
@property (nonatomic, strong) NSDictionary  *routeLine; //路线(存放数组)
@property (nonatomic, strong) NSDictionary  *extendDic; //扩展字段

- (NSString*)obtainRouteType;
- (NSString *)ontatinRulePrompt;
- (NSString*)obtainRouteRule;
- (BMKDrivingPolicy)obtainDrivingPolicy;

@end
