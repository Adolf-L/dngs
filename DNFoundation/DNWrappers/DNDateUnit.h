/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNDateUnit.h
 *
 * Description  : DNDateUnit
 *
 * Author       : eisen
 *
 * History      : Creation, 2018/4/14, Create the file
 *****************************************************************************************
 **/

#import <Foundation/Foundation.h>

@interface DNDateUnit : NSObject

+ (DNDateUnit *)sharedInstance;

- (NSString *)getStringDate:(NSDate *)date;

@end
