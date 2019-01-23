/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : NSString+Verify.m
 *
 * Description  : NSString+Verify
 *
 * Author       : eisen
 *
 * History      : Creation, 2018/3/8, Create the file
 *****************************************************************************************
 **/

#import "NSString+Verify.h"

@implementation NSString (Verify)

- (BOOL)isValidPhoneNumber
{
    if (self.length < 1) {
        // 还没有输入内容
        return NO;
    } else if (self.length != 11) {
        // 手机号码的长度不对
        return NO;
    } else {
        // 手机号码的匹配规则
        NSString *pattern = [NSString stringWithFormat:@"^1+[34578]+\\d{%ld}", (long)(self.length-2)];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
        return [pred evaluateWithObject:self];
    }
}

- (BOOL)isValidUsername
{
    if (self.length < 5 || self.length > 20) {
        return NO;
    }
    
    NSString *regex = @"^[A-Za-z0-9]{5,20}+$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:self];
}

- (BOOL)isValidPassword
{
    if (self.length < 6 || self.length > 20) {
        return NO;
    } else {
        return YES;
    }
}

@end
