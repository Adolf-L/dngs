/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNCustomSheetView.h
 *
 * Description  : DNCustomSheetView
 *
 * Author       : eisen
 *
 * History      : Creation, 2018/7/21, Create the file
 *****************************************************************************************
 **/

#import <UIKit/UIKit.h>

@protocol DNSheetViewDelegate <NSObject>

- (void)onSelectSheet:(NSString *)title;

@end

@interface DNCustomSheetView : UIView

@property (nonatomic, weak) id<DNSheetViewDelegate> delegate;

- (void)configWithItems:(NSArray *)itemsArray;

@end
