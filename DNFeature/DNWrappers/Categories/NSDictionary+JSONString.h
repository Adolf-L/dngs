/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : NSDictionary+JSONString.h
 *
 * Description  : NSDictionary+JSONString
 *
 * Author       : eisen
 *
 * History      : Creation, 2017/5/7, Create the file
 *****************************************************************************************
 **/

#import <Foundation/Foundation.h>

@interface NSDictionary (JSONString)

- (NSString*)convertToJSONString;

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

@end
