/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNProfileManager.h
 *
 * Description  : DNProfileManager
 *
 * Author       : eisen
 *
 * History      : Creation, 2018/7/10, Create the file
 *****************************************************************************************
 **/

#import <Foundation/Foundation.h>

typedef void (^DNRequestFinishBlock)(id obj);

@interface DNProfileManager : NSObject

@property (nonatomic, strong, readonly) NSString *version;
@property (nonatomic, assign, readonly) BOOL isAppStoreOK;
@property (nonatomic, assign, readonly) BOOL showFamily;
@property (nonatomic, assign, readonly) BOOL hasNewFamily;
@property (nonatomic, assign) BOOL hasNewNotice;

+ (DNProfileManager *)sharedInstance;

- (void)downloadiOSProfile;

@end
