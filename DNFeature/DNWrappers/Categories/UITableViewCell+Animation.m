/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : UITableViewCell+Animation.m
 *
 * Description  : UITableViewCell+Animation
 *
 * Author       : eisen
 *
 * History      : Creation, 2018/1/28, Create the file
 *****************************************************************************************
 **/

#import "UITableViewCell+Animation.h"
#import <objc/runtime.h>

#ifndef YYSYNTH_DYNAMIC_PROPERTY_CTYPE
#define YYSYNTH_DYNAMIC_PROPERTY_CTYPE(_getter_, _setter_, _type_) \
- (void)_setter_ : (_type_)object { \
[self willChangeValueForKey:@#_getter_]; \
NSValue *value = [NSValue value:&object withObjCType:@encode(_type_)]; \
objc_setAssociatedObject(self, _cmd, value, OBJC_ASSOCIATION_RETAIN); \
[self didChangeValueForKey:@#_getter_]; \
} \
- (_type_)_getter_ { \
_type_ cValue = { 0 }; \
NSValue *value = objc_getAssociatedObject(self, @selector(_setter_:)); \
[value getValue:&cValue]; \
return cValue; \
}
#endif

@implementation UITableViewCell (Animation)

YYSYNTH_DYNAMIC_PROPERTY_CTYPE(isDisplayed, setDisplayed, BOOL)

- (void)tableView:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath animationStyle:(SMCellDisplayAnimationStyle)animationStyle {
    if (!self.isDisplayed) {
        switch (animationStyle) {
            case SMCellDisplayAnimationTop: {
                CGRect originFrame = self.frame;
                CGRect frame = self.frame;
                frame.origin.y = -frame.size.height;
                self.frame = frame;
                
                NSTimeInterval duration = 0.1 + (NSTimeInterval)(indexPath.row) / 15.0;
                [UIView animateWithDuration:duration animations:^{
                    self.frame = originFrame;
                } completion:nil];
                break;
            }
            case SMCellDisplayAnimationLeft: {
                CGRect originFrame = self.frame;
                CGRect frame = self.frame;
                frame.origin.x = -frame.size.width;
                self.frame = frame;
                
                NSTimeInterval duration = 0.5 + (NSTimeInterval)(indexPath.row) / 10.0;
                [UIView animateWithDuration:duration animations:^{
                    self.frame = originFrame;
                } completion:nil];
                break;
            }
            case SMCellDisplayAnimationBottom: {
                self.alpha = 0;
                CGRect originFrame = self.frame;
                CGRect frame = self.frame;
                frame.origin.y = tableView.frame.size.height;
                self.frame = frame;
                
                NSTimeInterval duration = 0.6 + (NSTimeInterval)(indexPath.row) / 3.0;
                [UIView animateWithDuration:duration animations:^{
                    self.frame = originFrame;
                    self.alpha = 1;
                } completion:nil];
                break;
            }
            case SMCellDisplayAnimationRight: {
                CGRect originFrame = self.frame;
                CGRect frame = self.frame;
                frame.origin.x = tableView.frame.size.width;
                self.frame = frame;
                
                NSTimeInterval duration = 0.5 + (NSTimeInterval)(indexPath.row) / 10.0;
                [UIView animateWithDuration:duration animations:^{
                    self.frame = originFrame;
                } completion:nil];
                break;
            }
            case SMCellDisplayAnimationTopTogether: {
                CGRect originFrame = self.frame;
                CGRect frame = self.frame;
                frame.origin.y = -frame.size.height;
                self.frame = frame;
                
                NSTimeInterval duration = 0.5f;
                [UIView animateWithDuration:duration animations:^{
                    self.frame = originFrame;
                } completion:nil];
                break;
            }
            case SMCellDisplayAnimationLeftTogether: {
                CGRect originFrame = self.frame;
                CGRect frame = self.frame;
                frame.origin.x = -frame.size.width;
                self.frame = frame;
                
                NSTimeInterval duration = 0.5f;
                [UIView animateWithDuration:duration animations:^{
                    self.frame = originFrame;
                } completion:nil];
                break;
            }
            case SMCellDisplayAnimationBottomTogether: {
                CGRect originFrame = self.frame;
                CGRect frame = self.frame;
                frame.origin.y = tableView.frame.size.height;
                self.frame = frame;
                
                NSTimeInterval duration = 0.5;
                [UIView animateWithDuration:duration animations:^{
                    self.frame = originFrame;
                } completion:nil];
                break;
            }
            case SMCellDisplayAnimationRightTogether: {
                CGRect originFrame = self.frame;
                CGRect frame = self.frame;
                frame.origin.x = tableView.frame.size.width;
                self.frame = frame;
                
                NSTimeInterval duration = 0.5f;
                [UIView animateWithDuration:duration animations:^{
                    self.frame = originFrame;
                } completion:nil];
                break;
            }
            case SMCellDisplayAnimationFadeIn: {
                self.alpha = 0;
                
                NSTimeInterval duration = 0.5 + (NSTimeInterval)(indexPath.row) / 10.0;
                [UIView animateWithDuration:duration animations:^{
                    self.alpha = 1;
                } completion:nil];
                break;
            }
            case SMCellDisplayAnimationFadeInTogether: {
                self.alpha = 0;
                
                NSTimeInterval duration = 0.5;
                [UIView animateWithDuration:duration animations:^{
                    self.alpha = 1;
                } completion:nil];
                break;
            }
        }
        self.displayed = YES;
    }
}

@end
