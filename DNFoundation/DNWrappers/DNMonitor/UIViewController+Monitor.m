/*
 *****************************************************************************************
 * Copyright (C) Guangzhou Shen Ma Mobile Information technology Co., Ltd. All Rights Reserved
 *
 * File			: UIViewController+Monitor.m
 *
 * Description	: UIViewController_Monitor
 *
 * Author		: jingzhou.cjz@alibaba-inc.com
 *
 * History		: Creation, 2017/12/5, jingzhou.cjz@alibaba-inc.com, Create the file
 *****************************************************************************************
 **/

#import "UIViewController+Monitor.h"
#import <objc/runtime.h>
#import "SMMonitorLogView.h"

static SMMonitorLogView *sMonitorLogView;

@implementation UIViewController (Monitor)

#pragma mark - Life cycle

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleSEL:@selector(viewDidAppear:) withSEL:@selector(swizzled_viewDidAppear:)];
    });
}

- (void)swizzled_viewDidAppear:(BOOL)animated
{
    [self swizzled_viewDidAppear:animated];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self showAppMonitorView];
    });
}

#pragma mark - Privates

- (void)showAppMonitorView
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    sMonitorLogView = [SMMonitorLogView sharedInstance];
    sMonitorLogView.needShowLog = NO;
    [keyWindow addSubview:sMonitorLogView];
}

+ (void)swizzleSEL:(SEL)originalSEL withSEL:(SEL)swizzledSEL
{
    Class class = [self class];
    Method originalMethod = class_getInstanceMethod(class, originalSEL);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSEL);
    
    BOOL didAddMethod = class_addMethod(class,
                                        originalSEL,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSEL,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end
