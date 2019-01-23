/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNShareView.h
 *
 * Description  : DNShareView
 *
 * Author       : eisen
 *
 * History      : Creation, 2017/2/23, Create the file
 *****************************************************************************************
 **/

#import <UIKit/UIKit.h>

typedef void(^DNShareFinishBlock)();

@interface DNShareView : UIView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *publicContent;  //分享到朋友圈、QQ空间的文本内容
@property (nonatomic, copy) NSString *sessionContent; //分享到微信会话、QQ会话的文本内容
@property (nonatomic, strong) UIImage  *shareImage;
@property (nonatomic, copy) DNShareFinishBlock finishBlock;

- (void)showStartAnimation;

@end
