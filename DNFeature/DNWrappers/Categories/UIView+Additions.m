//
//  UIView+Additions.m
//  AVOSCloud
//
//  Created by eisen.chen on 2018/11/8.
//

#import "UIView+Additions.h"

@implementation UIView (Additions)

- (UIImage *)viewShot
{
    if (self && self.frame.size.height && self.frame.size.width) {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, self.opaque, [[UIScreen mainScreen] scale]);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    } else {
        return nil;
    }
}

@end
