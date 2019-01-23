/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNSettingGuideView.m
 *
 * Description  : DNSettingGuideView
 *
 * Author       : eisen
 *
 * History      : Creation, 2018/7/10, Create the file
 *****************************************************************************************
 **/

#import "DNSettingGuideView.h"

@interface DNSettingGuideView()<CALayerDelegate>

@property (nonatomic, strong) CALayer  *topCircleLayer;
@property (nonatomic, strong) CALayer  *btmCircleLayer;

@end

@implementation DNSettingGuideView

#pragma mark - Life cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self layoutGuideLayers:frame];
    }
    return self;
}

#pragma mark - Public

- (void)showAnimation
{
    NSArray *scales = @[@(0.2), @(1)];
    NSArray *widths1 = @[@(12), @(0)];
    NSArray *opacity = @[@(1), @(0.3)];
    CAAnimation *animation1 = [self animation:@"transform.scale" values:scales duration:2];
    CAAnimation *animation2 = [self animation:@"borderWidth" values:widths1 duration:2];
    CAAnimation *animation3 = [self animation:@"opacity" values:opacity duration:2];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.topCircleLayer.hidden = NO;
        self.btmCircleLayer.hidden = NO;
        [self.topCircleLayer addAnimation:animation1 forKey:@"animation1"];
        [self.topCircleLayer addAnimation:animation2 forKey:@"animation2"];
        [self.topCircleLayer addAnimation:animation3 forKey:@"animation3"];
    });
    
    NSArray *widths2 = @[@(6), @(0)];
    CAAnimation *animation4 = [self animation:@"borderWidth" values:widths2 duration:2];
    [self.btmCircleLayer addAnimation:animation1 forKey:@"animation1"];
    [self.btmCircleLayer addAnimation:animation4 forKey:@"animation4"];
    [self.btmCircleLayer addAnimation:animation3 forKey:@"animation3"];
}

- (void)stopAnimation
{
    [self.topCircleLayer removeAllAnimations];
    [self.btmCircleLayer removeAllAnimations];
}

#pragma mark - Privates

- (void)layoutGuideLayers:(CGRect)frame
{
    CGFloat radius = frame.size.width > frame.size.height ? frame.size.width/2 : frame.size.height/2;
    CGPoint center = CGPointMake(frame.origin.x + frame.size.width/2,
                                 frame.origin.y + frame.size.height/2);
    CGRect newFrame = CGRectMake(center.x - radius, center.y - radius, radius*2, radius*2);
    self.btmCircleLayer = [self createLayer:newFrame withWith:2 andColor:DNColor84DD77];
    self.btmCircleLayer.hidden = YES;
    [self.layer addSublayer:self.btmCircleLayer];
    
    CGFloat newRadius = radius * 0.7;
    newFrame = CGRectMake(center.x - newRadius, center.y - newRadius, newRadius*2, newRadius*2);
    self.topCircleLayer = [self createLayer:newFrame withWith:8 andColor:DNColor27C411];
    self.topCircleLayer.hidden = YES;
    [self.layer addSublayer:self.topCircleLayer];
}

- (CALayer *)createLayer:(CGRect)frame withWith:(CGFloat)width andColor:(UIColor *)color
{
    CALayer *retLayer = [CALayer layer];
    retLayer.frame = frame;
    retLayer.cornerRadius = frame.size.width/2;
    retLayer.borderWidth = width;
    retLayer.borderColor = color.CGColor;
    retLayer.backgroundColor = [UIColor clearColor].CGColor;
    return retLayer;
}

- (CAAnimation *)animation:(NSString *)keyPath values:(NSArray *)values duration:(CFTimeInterval)duration
{
    CAKeyframeAnimation *animate = [CAKeyframeAnimation animationWithKeyPath:keyPath];
    animate.values      = values;
    animate.duration    = duration;
    animate.repeatCount = INT_MAX;
    animate.fillMode = kCAFillModeBoth;
    animate.removedOnCompletion = YES;
    return animate;
}

@end
