/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : UIImage+Additions.m
 *
 * Description  : UIImage+Additions
 *
 * Author       : eisen
 *
 * History      : Creation, 2018/7/25, Create the file
 *****************************************************************************************
 **/

#import "UIImage+Additions.h"

@implementation UIImage (Additions)

//  颜色转换为背景图片
+ (UIImage *)imageFromColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
