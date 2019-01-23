/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNCollectionUnit.h
 *
 * Description  : DNCollectionUnit
 *
 * Author       : eisen
 *
 * History      : Creation, 2017/10/28, Create the file
 *****************************************************************************************
 **/

#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSInteger, DNCollectResult) {
    DNCollectOK,      // 收藏成功
    DNCollectExist,   // 已经存在
    DNCollectFailed   // 收藏失败
};

@interface DNCollectionUnit : NSObject

+ (BOOL)collectCoord:(CLLocationCoordinate2D)coord withAddress:(NSString *)address;

+ (BOOL)historyCoord:(CLLocationCoordinate2D)coord withAddress:(NSString *)address;

+ (DNCollectResult)collectRouteLine:(NSString *)bundleID;

+ (BOOL)updateCollectRoute:(NSString *)bundleID withName:(NSString *)name;

+ (BOOL)deleteCollectRoute:(NSString *)bundleID;

@end
