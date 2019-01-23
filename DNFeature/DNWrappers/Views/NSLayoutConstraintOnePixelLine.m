/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : NSLayoutConstraintOnePixelLine.m
 *
 * Description  : NSLayoutConstraintOnePixelLine
 *
 * Author       : eisen
 *
 * History      : Creation, 2018/6/23, Create the file
 *****************************************************************************************
 **/

#import "NSLayoutConstraintOnePixelLine.h"

@implementation NSLayoutConstraintOnePixelLine

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    if (self.constant == 1) {
        self.constant = 1 / [UIScreen mainScreen].scale;
    }
}

@end
