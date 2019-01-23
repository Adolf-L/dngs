/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNFormatGps.h
 *
 * Description  : DNFormatGps
 *
 * Author       : eisen
 *
 * History      : Creation, 2017/2/7, Create the file
 *****************************************************************************************
 **/

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface DNFormatGps: NSObject

+ (instancetype)sharedIntances;
// 火星坐标转为GPS
- (CLLocationCoordinate2D)gcjToGPS:(CLLocationCoordinate2D)gcjCoor;
// GPS转为火星坐标
- (CLLocationCoordinate2D)gpsToGCJ:(double)gpsLat gpsLon:(double)gpsLon;

- (CLLocationCoordinate2D)gpsToGCJ:(CLLocationCoordinate2D)gpsCoor;
// 百度坐标转为火星坐标
- (CLLocationCoordinate2D)baiduGpsToGCJ:(CLLocationCoordinate2D)baiduGps;
// 火星转换为百度坐标
- (CLLocationCoordinate2D)gcjToBaiduGPS:(CLLocationCoordinate2D)fireGps;
@end
