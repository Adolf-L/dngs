//
//  DNPointRuleView.h
//  DNFeature
//
//  Created by eisen.chen on 2018/9/7.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DNPointRule) {
    DNPointRuleCenter = 0,
    DNPointRuleTop = 1,
    DNPointRuleLeft = 2,
    DNPointRuleBootom = 3,
    DNPointRuleRight = 4
};

@protocol DNPointRuleViewDelegate <NSObject>

- (void)onPointRuleChange:(DNPointRule)pointRule;

@end

@interface DNPointRuleView : UIView

@property (nonatomic, weak) id<DNPointRuleViewDelegate> delegate;

- (void)showContentWithCenter:(CGPoint)center andSize:(CGSize)size;

- (void)close;

@end
