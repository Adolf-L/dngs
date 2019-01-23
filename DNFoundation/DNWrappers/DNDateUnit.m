/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNDateUnit.m
 *
 * Description  : DNDateUnit
 *
 * Author       : eisen
 *
 * History      : Creation, 2018/4/14, Create the file
 *****************************************************************************************
 **/

#import "DNDateUnit.h"

@implementation DNDateUnit

+ (DNDateUnit *)sharedInstance
{
    static DNDateUnit *dateUnit = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateUnit = [[DNDateUnit alloc] init];
    });
    return dateUnit;
}

- (NSString *)getStringDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM/dd hh:mm"];
    return [dateFormatter stringFromDate:date];
}

@end
