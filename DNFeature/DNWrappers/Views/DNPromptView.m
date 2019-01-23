/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNPromptView.m
 *
 * Description  : DNPromptView
 *
 * Author       : eisen
 *
 * History      : Creation, 2018/3/15, Create the file
 *****************************************************************************************
 **/

#import "DNPromptView.h"

@interface DNPromptView ()

@property (nonatomic, strong) MBProgressHUD *statusView;

@end

@implementation DNPromptView

+ (DNPromptView *)sharedInstance
{
    static DNPromptView *promptView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        promptView = [[DNPromptView alloc] init];
    });
    return promptView;
}

+ (void)showToast:(NSString*)text
{
    if (!text || ![text isKindOfClass:[NSString class]]) {
        return ;
    }
    
    UIWindow* window = [[UIApplication sharedApplication].delegate window];
    MBProgressHUD *toast = [[MBProgressHUD alloc] init];
    toast.mode  = MBProgressHUDModeText;
    toast.label.text = text;
    toast.label.textColor = [UIColor whiteColor];
    toast.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    toast.bezelView.color = [UIColor colorWithHex:0x1D1D1D alpha:0.88];
    [window addSubview:toast];
    [toast showAnimated:YES];
    [toast hideAnimated:YES afterDelay:1.2];
}

- (void)showLoadingView
{
    if (self.statusView) {
        [self.statusView hideAnimated:YES];
    }
    
    UIView *parentView = [UIViewController currentViewController].view;
    self.statusView = [MBProgressHUD showHUDAddedTo:parentView animated:YES];
    self.statusView.contentColor = [UIColor whiteColor];
    self.statusView.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    self.statusView.bezelView.color = [UIColor colorWithHex:0x1D1D1D alpha:0.88];
}

- (void)showLoadingText:(NSString *)text
{
    if (self.statusView) {
        [self.statusView hideAnimated:YES];
    }
    
    UIView *parentView = [UIViewController currentViewController].view;
    self.statusView = [MBProgressHUD showHUDAddedTo:parentView animated:YES];
    self.statusView.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    self.statusView.bezelView.color = [UIColor colorWithHex:0x1D1D1D alpha:0.88];
    self.statusView.label.textColor = [UIColor whiteColor];
    self.statusView.label.text = text;
    self.statusView.contentColor = [UIColor whiteColor];
}

- (void)showText:(NSString *)text andRemove:(NSTimeInterval)time
{
    if (self.statusView) {
        [self.statusView hideAnimated:YES];
    }
    
    UIView *parentView = [UIViewController currentViewController].view;
    self.statusView = [MBProgressHUD showHUDAddedTo:parentView animated:YES];
    self.statusView.mode = MBProgressHUDModeText;
    self.statusView.label.text = text;
    self.statusView.label.textColor = [UIColor whiteColor];
    self.statusView.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    self.statusView.bezelView.color = [UIColor colorWithHex:0x1D1D1D alpha:0.88];
    [self.statusView hideAnimated:YES afterDelay:time];
}

- (void)showDetailText:(NSString *)detail andRemove:(NSTimeInterval)time
{
    if (self.statusView) {
        [self.statusView hideAnimated:YES];
    }
    
    UIView *parentView = [UIViewController currentViewController].view;
    self.statusView = [MBProgressHUD showHUDAddedTo:parentView animated:YES];
    self.statusView.detailsLabel.textColor = [UIColor whiteColor];
    self.statusView.label.textColor = [UIColor whiteColor];
    self.statusView.detailsLabel.font = DNFont12;
    self.statusView.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    self.statusView.bezelView.color = [UIColor colorWithHex:0x1D1D1D alpha:0.88];
    self.statusView.mode = MBProgressHUDModeText;
    self.statusView.detailsLabel.text = detail;
    [self.statusView hideAnimated:YES afterDelay:time];
}

- (void)showVipWithText:(NSString *)detail andRemove:(NSTimeInterval)time
{
    if (self.statusView) {
        [self.statusView hideAnimated:YES];
    }
    
    UIImageView *vipView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    vipView.image = [UIImage imageNamed:@"DNFeature.bundle/charge_success"];
    
    UIView *parentView = [UIViewController currentViewController].view;
    self.statusView = [MBProgressHUD showHUDAddedTo:parentView animated:YES];
    self.statusView.mode = MBProgressHUDModeCustomView;
    self.statusView.customView = vipView;
    self.statusView.detailsLabel.text = detail;
    self.statusView.detailsLabel.textColor = [UIColor whiteColor];
    self.statusView.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    self.statusView.bezelView.color = [UIColor colorWithHex:0x1D1D1D alpha:0.88];
    [self.statusView hideAnimated:YES afterDelay:time];
}

- (void)hideView:(NSTimeInterval)time
{
    if (time > 0) {
        [self.statusView hideAnimated:YES afterDelay:time];
    } else {
        [self.statusView hideAnimated:YES];
    }
}

@end
