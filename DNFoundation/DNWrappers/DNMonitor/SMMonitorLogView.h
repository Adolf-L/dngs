/*
 *****************************************************************************************
 * Copyright (C) Guangzhou Shen Ma Mobile Information technology Co., Ltd. All Rights Reserved
 *
 * File			: SMMonitorLogView.h
 *
 * Description	: SMMonitorLogView
 *
 * Author		: jingzhou.cjz@alibaba-inc.com
 *
 * History		: Creation, 2017/12/6, jingzhou.cjz@alibaba-inc.com, Create the file
 *****************************************************************************************
 **/

#import <UIKit/UIKit.h>

@interface SMMonitorLogView : UIView

@property (nonatomic, assign) BOOL needShowLog; //默认关闭，展示LogView时需要手动打开

+ (SMMonitorLogView *)sharedInstance;

@end
