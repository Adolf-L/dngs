/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNAlertView.h
 *
 * Description  : DNAlertView
 *
 * Author       : eisen
 *
 * History      : Creation, 2018/1/21, Create the file
 *****************************************************************************************
 **/

#import <Foundation/Foundation.h>

typedef void (^confirm)();
typedef void (^cancle)();

typedef void (^sheetAction)(NSString * _Nonnull title);

NS_ASSUME_NONNULL_BEGIN

@interface DNAlertView : NSObject

/**
 展示alert提示框
 
 @param title        alert提示内容的标题
 @param message      alert提示内容的说明
 @param firstTitle   第一个操作标题
 @param firstAction  第一个操作的响应处理
 @param secondTitle  第二个操作标题
 @param secondAction 第二个操作的响应处理
 */
+ (void)showAlert:(NSString *_Nonnull)title
          message:(NSString *_Nullable)message
       firstTitle:(NSString *_Nonnull)firstTitle
      firstAction:(void (^_Nullable)())firstAction
      secondTitle:(NSString *_Nullable)secondTitle
     secondAction:(void (^_Nullable)())secondAction;

/**
 展示sheet选择框
 */
+ (void)showSheetWithTitle:(NSString *)title
                    Values:(NSArray *_Nonnull)values
                 andAction:(sheetAction _Nullable)finishAction
                    cancel:(sheetAction _Nullable)cancleAction;

@end

NS_ASSUME_NONNULL_END
