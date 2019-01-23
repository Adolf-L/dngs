//
//  DNRoutePointView.m
//  DNFeature
//
//  Created by eisen.chen on 2018/8/30.
//

#import "DNRoutePointView.h"

@interface DNRoutePointView()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation DNRoutePointView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self layoutRoutePointView];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
}

- (void)layoutRoutePointView
{
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.bounds];
    imgView.image = [UIImage imageNamed:@"DNFeature.bundle/route_path_selecting"];
    [self addSubview:imgView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    self.titleLabel.textColor = DNColor2196F3;
    self.titleLabel.font = DNFont12;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.titleLabel];
}

@end
