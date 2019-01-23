/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNRouteAppCell.m
 *
 * Description  : DNRouteAppCell
 *
 * Author       : eisen
 *
 * History      : Creation, 2017/2/19, Create the file
 *****************************************************************************************
 **/

#import "DNRouteAppCell.h"

@implementation DNRouteAppCell

- (IBAction)actionAppInfoSwitch:(UISwitch *)sender
{
    if ([self.delegate respondsToSelector:@selector(onSwitchChange:withIndexPath:)]) {
        [self.delegate onSwitchChange:[sender isOn] withIndexPath:self.indexPath];
    }
}

@end
