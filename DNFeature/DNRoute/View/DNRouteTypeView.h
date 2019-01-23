/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNRouteTypeView.h
 *
 * Description  : DNRouteTypeView
 *
 * Author       : eisen
 *
 * History      : Creation, 2018/6/27, Create the file
 *****************************************************************************************
 **/

#import <UIKit/UIKit.h>
#import "DNRouteModel.h"

@protocol DNRouteTypeViewDelegate<NSObject>

- (void)didChangeType:(DNRouteType)type;

- (void)onSettingDetail;

@end

@interface DNRouteTypeView : UIView

@property (nonatomic, weak) id<DNRouteTypeViewDelegate> delegate;

- (void)refreshTypeView:(DNRouteType)type;

- (void)showGuideGIF;

- (void)removeGuideGIF;

@end
