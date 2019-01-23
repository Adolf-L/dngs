/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNTipView.h
 *
 * Description  : DNTipView
 *
 * Author       : eisen
 *
 * History      : Creation, 2017/3/29, Create the file
 *****************************************************************************************
 **/

#import <UIKit/UIKit.h>

@interface DNTipView : UIView

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

- (void)showStartAnimation;

@end
