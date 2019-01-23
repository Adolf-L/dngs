/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : CALayer+Add.m
 *
 * Description  : CALayer+Add
 *
 * Author       : eisen
 *
 * History      : Creation, 2017/2/15, Create the file
 *****************************************************************************************
 **/

#import "CALayer+Add.h"

@implementation CALayer (Add)

-(void)setBorderUIColor:(UIColor*)color
{
    self.borderColor = color.CGColor;
}

-(UIColor *)borderUIColor
{
    return [UIColor colorWithCGColor:self.borderColor];
}

-(void)setShadowUIColor:(UIColor*)color
{
    self.shadowColor = color.CGColor;
}

-(UIColor *)shadowUIColor
{
    return [UIColor colorWithCGColor:self.shadowColor];
}

@end
