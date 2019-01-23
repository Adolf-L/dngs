/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : UIColor+Add.h
 *
 * Description  : UIColor+Add
 *
 * Author       : eisen
 *
 * History      : Creation, 2017/2/7, Create the file
 *****************************************************************************************
 **/

#import <UIKit/UIKit.h>

@interface UIColor (Add)

/**
 色值转换成UIColor

 @param hexColor 16进制色值
 @return UIColor类型
 */
+ (UIColor *)colorWithHex:(long)hexColor;

/**
 色值转换成UIColor

 @param hexColor 16进制色值
 @param opacity 颜色的透明度0~1
 @return UIColor类型
 */
+ (UIColor *)colorWithHex:(long)hexColor alpha:(CGFloat)opacity;

@end
