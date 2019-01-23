/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNPromptView.h
 *
 * Description  : DNPromptView
 *
 * Author       : eisen
 *
 * History      : Creation, 2018/3/15, Create the file
 *****************************************************************************************
 **/

#import <Foundation/Foundation.h>

@interface DNPromptView : NSObject

+ (DNPromptView *)sharedInstance;

+ (void)showToast:(NSString*)text;

- (void)showLoadingView;

- (void)showLoadingText:(NSString *)text;

- (void)showText:(NSString *)text andRemove:(NSTimeInterval)time;

- (void)showDetailText:(NSString *)detail andRemove:(NSTimeInterval)time;

- (void)showVipWithText:(NSString *)detail andRemove:(NSTimeInterval)time;

- (void)hideView:(NSTimeInterval)time;

@end
