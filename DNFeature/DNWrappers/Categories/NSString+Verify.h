/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : NSString+Verify.h
 *
 * Description  : NSString+Verify
 *
 * Author       : eisen
 *
 * History      : Creation, 2018/3/8, Create the file
 *****************************************************************************************
 **/

#import <Foundation/Foundation.h>

@interface NSString (Verify)

- (BOOL)isValidPhoneNumber;

/**
 判断用户名字符串是否合法
 
 1.长度在5-20位；
 2.由英文字母和数字组成
 */
- (BOOL)isValidUsername;

/**
 判断密码字符串是否合法: 长度在6-20位
 */
- (BOOL)isValidPassword;

@end
