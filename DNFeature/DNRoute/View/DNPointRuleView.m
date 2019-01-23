//
//  DNPointRuleView.m
//  DNFeature
//
//  Created by eisen.chen on 2018/9/7.
//

#import "DNPointRuleView.h"
#import "DNPointRuleViewCell.h"

#define kContentWidth  290
#define kContentHeight 280

@interface DNPointRuleView()<UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *pointRuleView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *ruleBtns;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pointRuleViewCenterY;

@property (nonatomic, assign) CGPoint originCenter;
@property (nonatomic, assign) CGSize  originSize;

@end

@implementation DNPointRuleView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self layoutRuleView];
}

#pragma mark - Public

- (void)showContentWithCenter:(CGPoint)center andSize:(CGSize)size
{
    self.hidden = NO;
    self.originSize = size;
    self.originCenter = center;
    self.pointRuleView.center = center;
    
    CGFloat widthRate  = size.width/kScreenWidth;
    CGFloat heightRate = size.height/kScreenHeight;
    self.pointRuleView.layer.transform = CATransform3DMakeScale(widthRate, heightRate, 1);
    [UIView animateWithDuration:0.3 animations:^{
        self.pointRuleView.layer.transform = CATransform3DMakeScale(1, 1, 1);
        self.pointRuleView.center = CGPointMake(kScreenWidth/2, kScreenHeight/2);
        self.pointRuleView.alpha = 1;
        self.backgroundColor = [UIColor colorWithHex:0x1D1D1D alpha:0.4];
        [self layoutIfNeeded];
    }];
}

- (void)close
{
    CGFloat widthRate  = self.originSize.width/kScreenWidth;
    CGFloat heightRate = self.originSize.height/kScreenHeight;
    [UIView animateWithDuration:0.3 animations:^{
        self.pointRuleView.alpha = 0;
        self.pointRuleView.center = self.originCenter;
        self.pointRuleView.layer.transform = CATransform3DMakeScale(widthRate, heightRate, 1);
        self.backgroundColor = [UIColor colorWithHex:0x1D1D1D alpha:0];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

#pragma mark - Actions

- (IBAction)onSelectRule:(UIButton *)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:@(sender.tag) forKey:kNewPointRule];
    if ([self.delegate respondsToSelector:@selector(onPointRuleChange:)]) {
        [self.delegate onPointRuleChange:sender.tag];
    }
    for (UIButton *ruleBtn in self.ruleBtns) {
        ruleBtn.selected = (ruleBtn == sender);
    }
    [self close];
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return YES;
}

#pragma mark - Privates

- (void)layoutRuleView
{
    self.backgroundColor = [UIColor colorWithHex:0x1D1D1D alpha:0];
    self.pointRuleView.alpha = 0;
    self.pointRuleViewCenterY.constant = 50;
    
    DNPointRule pointRule = [[[NSUserDefaults standardUserDefaults] valueForKey:kNewPointRule] integerValue];
    for (UIButton *ruleBtn in self.ruleBtns) {
        ruleBtn.selected = (ruleBtn.tag == pointRule);
    }
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handleTapView:)];
    tapGesture.delegate = self;
    [self addGestureRecognizer:tapGesture];
}

- (void)handleTapView:(UITapGestureRecognizer *)sender
{
    [self close];
}

@end
