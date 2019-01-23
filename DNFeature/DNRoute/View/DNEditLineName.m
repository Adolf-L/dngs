//
//  DNEditLineName.m
//  AVOSCloud
//
//  Created by eisen.chen on 2018/12/12.
//

#import "DNEditLineName.h"

@interface DNEditLineName () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView      *contentView;
@property (weak, nonatomic) IBOutlet UILabel     *promptLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (nonatomic, assign) NSInteger maxCount;
@property (nonatomic, assign) CGPoint originCenter;
@property (nonatomic, assign) CGSize  originSize;

@end

@implementation DNEditLineName

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.nameTextField.delegate = self;
    if (kScreenWidth > 375) {
        self.maxCount = 12;
    } else if (kScreenWidth > 320) {
        self.maxCount = 10;
    } else {
        self.maxCount = 8;
    }
    self.promptLabel.text = [NSString stringWithFormat:@"0/%ld", self.maxCount];
}

#pragma mark - Public methods

- (void)setContentFrame:(CGRect)frame
{
    self.hidden = NO;
    
    CGFloat centerX = frame.origin.x + frame.size.width/2;
    CGFloat centerY = frame.origin.y + frame.size.height/2;
    self.originSize = frame.size;
    self.originCenter = CGPointMake(centerX, centerY);
    
    CGFloat widthRate  = frame.size.width/(kScreenWidth - 32);
    CGFloat heightRate = frame.size.height/150;
    self.contentView.alpha = 0;
    self.contentView.center = CGPointMake(centerX, centerY);
    self.contentView.layer.transform = CATransform3DMakeScale(widthRate, heightRate, 1);
    self.backgroundColor = [UIColor colorWithHex:0x1D1D1D alpha:0];
    [UIView animateWithDuration:0.3 animations:^{
        self.contentView.layer.transform = CATransform3DMakeScale(1, 1, 1);
        CGFloat newCenterY = kScreenHeight/2;
        if (newCenterY - 75 < 300) {
            newCenterY = 375;
        }
        self.contentView.center = CGPointMake(kScreenWidth/2, newCenterY);
        self.contentView.alpha = 1;
        self.backgroundColor = [UIColor colorWithHex:0x1D1D1D alpha:0.3];
        [self layoutIfNeeded];
    }];
    [self.nameTextField becomeFirstResponder];
}

#pragma mark - Events

- (IBAction)onCancel:(UIButton *)sender
{
    [self closeWithResult:nil];
}

- (IBAction)onFinish:(UIButton *)sender
{
    [self closeWithResult:self.nameTextField.text];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSInteger newLen = textField.text.length - range.length + string.length;
    if (newLen <= self.maxCount) {
        self.promptLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)newLen, (long)self.maxCount];
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.nameTextField resignFirstResponder];
    return YES;
}

#pragma mark - Private methods

- (void)closeWithResult:(NSString *)result
{
    CGFloat widthRate  = self.originSize.width/(kScreenWidth - 32);
    CGFloat heightRate = self.originSize.height/150;
    [UIView animateWithDuration:0.3 animations:^{
        self.contentView.alpha = 0;
        self.contentView.center = self.originCenter;
        self.contentView.layer.transform = CATransform3DMakeScale(widthRate, heightRate, 1);
        self.backgroundColor = [UIColor colorWithHex:0x1D1D1D alpha:0];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (result.length > 0 && self.callBack) {
            self.callBack(result);
        }
        self.hidden = YES;
    }];
    [self.nameTextField resignFirstResponder];
}

@end
