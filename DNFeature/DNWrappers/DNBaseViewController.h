/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNBaseViewController.h
 *
 * Description  : DNBaseViewController
 *
 * Author       : eisen
 *
 * History      : Creation, 2017/9/17, Create the file
 *****************************************************************************************
 **/

#import <UIKit/UIKit.h>

@interface DNBaseViewController : UIViewController

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *menuBtn;
@property (nonatomic, strong, readonly) UIView *navigationView;

- (void)configWithParams:(NSDictionary *)params;

- (void)hideNavigationView;

- (void)actionBack;

- (void)actionMenu;

@end
