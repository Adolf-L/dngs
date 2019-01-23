/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNRouteSettingView.h
 *
 * Description  : DNRouteSettingView
 *
 * Author       : eisen
 *
 * History      : Creation, 2018/7/4, Create the file
 *****************************************************************************************
 **/

#import <UIKit/UIKit.h>
#import "DNRouteModel.h"

@protocol DNRouteSettingViewDelegate<NSObject>

- (void)handleSettingResult:(DNRouteModel *)routeModel andRefresh:(BOOL)refresh;

@end

@interface DNRouteSettingView : UIView

@property (nonatomic, weak) id<DNRouteSettingViewDelegate> delegate;

- (void)configWithModel:(DNRouteModel *)routeModel;

- (void)stopSetting;

@end
