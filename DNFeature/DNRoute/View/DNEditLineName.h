//
//  DNEditLineName.h
//  AVOSCloud
//
//  Created by eisen.chen on 2018/12/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DNEditLineName : UIView

@property (nonatomic, copy) DNCallBackBlock callBack;

- (void)setContentFrame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
