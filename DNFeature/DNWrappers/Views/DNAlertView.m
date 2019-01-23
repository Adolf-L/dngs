/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNAlertView.m
 *
 * Description  : DNAlertView
 *
 * Author       : eisen
 *
 * History      : Creation, 2018/1/21, Create the file
 *****************************************************************************************
 **/

#import "DNAlertView.h"
#import "DNCustomSheetView.h"

@interface DNAlertView()<DNSheetViewDelegate>

@property (nonatomic, copy) confirm firstAction;
@property (nonatomic, copy) cancle  secondAction;
@property (nonatomic, copy) sheetAction confimAction;
@property (nonatomic, copy) sheetAction cancleAction;

@end

@implementation DNAlertView

+ (void)showAlert:(NSString *_Nonnull)title
          message:(NSString *_Nullable)message
       firstTitle:(NSString *_Nonnull)firstTitle
      firstAction:(void (^_Nullable)())firstAction
      secondTitle:(NSString *_Nullable)secondTitle
     secondAction:(void (^_Nullable)())secondAction
{
    [[DNPromptView sharedInstance] hideView:0];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    if (firstTitle) {
        [alertController addAction:[UIAlertAction actionWithTitle:firstTitle
                                                            style:UIAlertActionStyleCancel
                                                          handler:firstAction]];
    }
    if (secondTitle) {
        [alertController addAction:[UIAlertAction actionWithTitle:secondTitle
                                                            style:UIAlertActionStyleDefault
                                                          handler:secondAction]];
    }
    UIViewController *rootVC = [[self class] currentViewController];
    [rootVC presentViewController:alertController animated:YES completion:nil];
}

+ (void)showSheetWithTitle:(NSString *)title
                    Values:(NSArray *_Nonnull)values
                 andAction:(sheetAction _Nullable)finishAction
                    cancel:(sheetAction _Nullable)cancleAction
{
    [[DNPromptView sharedInstance] hideView:0.3];
    
    UIAlertController *sheetController = [UIAlertController alertControllerWithTitle:title
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSString *title in values) {
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:title
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * _Nonnull action) {
                                                                if (finishAction) {
                                                                    finishAction(action.title);
                                                                }
                                                            }];
        if (@available(iOS 9, *)) {
            [alertAction setValue:[UIColor colorWithWhite:0 alpha:0.9] forKey:@"titleTextColor"];
        }
        [sheetController addAction:alertAction];
    }
    [sheetController addAction:[UIAlertAction actionWithTitle:@"取消"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          if (cancleAction) {
                                                              cancleAction(action.title);
                                                          }
                                                      }]];
    UIPopoverPresentationController *popover = sheetController.popoverPresentationController;
    if (popover) {
        CGFloat screenWidth  = [UIScreen mainScreen].bounds.size.width;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        popover.sourceView = [UIViewController currentViewController].view;
        popover.sourceRect = CGRectMake(0, screenHeight, screenWidth, screenHeight);
        popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
    }
    
    UIViewController *rootVC = [[self class] currentViewController];
    [rootVC presentViewController:sheetController animated:YES completion:nil];
}

- (void)showSheetWithValues:(NSArray *_Nonnull)values
                  andAction:(sheetAction _Nullable)action
                     cancel:(sheetAction _Nullable)cancel
{
    [[DNPromptView sharedInstance] hideView:0];
    
    self.confimAction = action;
    self.cancleAction = cancel;
    
    if (@available(iOS 8, *)) {
        UIAlertController *sheetController = [UIAlertController alertControllerWithTitle:nil
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
        for (NSString *title in values) {
            UIAlertAction *alertAction = [UIAlertAction actionWithTitle:title
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * _Nonnull action) {
                                                                    if (self.confimAction) {
                                                                        self.confimAction(action.title);
                                                                    }
                                                                }];
            if (@available(iOS 9, *)) {
                [alertAction setValue:[UIColor colorWithWhite:0 alpha:0.9] forKey:@"titleTextColor"];
            }
            [sheetController addAction:alertAction];
        }
        [sheetController addAction:[UIAlertAction actionWithTitle:@"取消"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              if (self.cancleAction) {
                                                                  self.cancleAction(action.title);
                                                              }
                                                          }]];
        
        UIViewController *rootVC = [[self class] currentViewController];
        [rootVC presentViewController:sheetController animated:YES completion:nil];
    } else {
        DNCustomSheetView *sheetView = [[DNCustomSheetView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        sheetView.delegate = self;
        [[[self class] currentViewController].view addSubview:sheetView];
        [sheetView configWithItems:values];
    }
}

+ (UIViewController *)currentViewController
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIViewController *vc = keyWindow.rootViewController;
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
        
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = [(UINavigationController *)vc visibleViewController];
        } else if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = [(UITabBarController *)vc selectedViewController];
        }
    }
    return vc;
}

#pragma mark - DNSheetViewDelegate

- (void)onSelectSheet:(NSString *)title
{
    if ([title isEqualToString:@"取消"]) {
        if (self.cancleAction) {
            self.cancleAction(@"取消");
        }
    } else {
        if (self.confimAction) {
            self.confimAction(title);
        }
    }
}

@end
