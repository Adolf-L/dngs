/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNTipView.m
 *
 * Description  : DNTipView
 *
 * Author       : eisen
 *
 * History      : Creation, 2017/3/29, Create the file
 *****************************************************************************************
 **/

#import "DNTipView.h"

@interface DNTipView()

@property (weak, nonatomic) IBOutlet UIView *tipView;

@end

@implementation DNTipView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.frame = [UIScreen mainScreen].bounds;
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapTipView:)];
    [self addGestureRecognizer:tapGesture];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showStartAnimation];
    });
}

- (void)showStartAnimation
{
    self.tipView.hidden = NO;
    self.tipView.layer.transform = CATransform3DMakeScale(1, 0.05, 1);
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundColor = [UIColor colorWithHex:0x373737 alpha:0.7];
        self.tipView.layer.transform = CATransform3DMakeScale(1, 1, 1);
        [self layoutIfNeeded];
    }];
}

- (IBAction)onCopyAddressInfo:(UIButton *)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [NSString stringWithFormat:@"%@, %@", self.addressLabel.text, self.detailLabel.text];
    
    [self actionTapTipView:nil];
    [[DNPromptView sharedInstance] showText:@"已复制位置信息到粘贴板" andRemove:1.2];
}

- (IBAction)actionTapTipView:(id)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundColor = [UIColor colorWithHex:0x373737 alpha:0];
        self.tipView.layer.transform = CATransform3DMakeScale(1, 0.05, 1);
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
