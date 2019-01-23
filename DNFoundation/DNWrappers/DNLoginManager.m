/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNLoginManager.m
 *
 * Description  : DNLoginManager
 *
 * Author       : eisen
 *
 * History      : Creation, 2018/3/29, Create the file
 *****************************************************************************************
 **/

#import "DNLoginManager.h"

@implementation DNLoginManager

+ (DNLoginManager *)sharedInstance
{
    static DNLoginManager *sLoginManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sLoginManager = [[DNLoginManager alloc] init];
    });
    return sLoginManager;
}

@end
