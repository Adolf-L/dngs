/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNBaseViewController.m
 *
 * Description  : DNBaseViewController
 *
 * Author       : eisen
 *
 * History      : Creation, 2017/9/17, Create the file
 *****************************************************************************************
 **/

#import "DNBaseViewController.h"

@interface DNBaseViewController ()

@property (nonatomic, strong) UIView *navigationView;

@end

@implementation DNBaseViewController

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self layoutNavigationBar];
}

- (void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
    
    if (@available(iOS 11, *)) {
        UIEdgeInsets safeEdge = self.view.safeAreaInsets;
        [self.navigationView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(safeEdge.top);
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}

#pragma mark - Publics

- (void)configWithParams:(NSDictionary *)params
{
    
}

- (void)hideNavigationView
{
    self.navigationView.hidden = YES;
}

- (void)actionBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)actionMenu
{
}

#pragma mark - Privates

- (void)layoutNavigationBar
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationView = [[UIView alloc] init];
    self.navigationView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.navigationView];
    
    UIButton *backBtn = [[UIButton alloc] init];
    backBtn.backgroundColor = [UIColor whiteColor];
    [backBtn setImage:[UIImage imageNamed:@"DNFeature.bundle/nav_back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(actionBack) forControlEvents:UIControlEventTouchDown];
    [self.navigationView addSubview:backBtn];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.backgroundColor = [UIColor whiteColor];
    self.titleLabel.font = DNFont18;
    self.titleLabel.textColor = DNColor1D1D1D;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.navigationView addSubview:self.titleLabel];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = DNColorD6D6D6;
    [self.navigationView addSubview:lineView];
    
    [self.navigationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(20);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(@(44));
    }];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navigationView);
        make.left.bottom.equalTo(self.navigationView);
        make.width.mas_equalTo(@(50));
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navigationView);
        make.bottom.equalTo(self.navigationView);
        make.centerX.equalTo(self.navigationView.mas_centerX);
    }];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.navigationView);
        make.height.mas_equalTo(@(1/[UIScreen mainScreen].scale));
    }];
    [self.view layoutIfNeeded];
}

#pragma mark - Getters

- (UIButton *)menuBtn
{
    if (!_menuBtn) {
        _menuBtn = [[UIButton alloc] init];
        _menuBtn.backgroundColor = [UIColor whiteColor];
        [_menuBtn setImage:[UIImage imageNamed:@"DNAssignApp.bundle/ic_Spinner"] forState:UIControlStateNormal];
        [_menuBtn addTarget:self action:@selector(actionMenu) forControlEvents:UIControlEventTouchDown];
        [self.navigationView addSubview:_menuBtn];
        
        [_menuBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.navigationView).offset(20);
            make.bottom.right.equalTo(self.navigationView).offset(-1);
            make.width.mas_equalTo(@(50));
        }];
    }
    return _menuBtn;
}

@end
