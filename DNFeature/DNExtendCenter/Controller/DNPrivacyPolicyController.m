//
//  DNPrivacyPolicyController.m
//  DNFeature
//
//  Created by eisen.chen on 2018/9/6.
//

#import "DNPrivacyPolicyController.h"

@interface DNPrivacyPolicyController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBottom;

@end

@implementation DNPrivacyPolicyController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.text = @"使用条款和隐私政策";
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
    
    if (@available(iOS 11, *)) {
        self.textViewBottom.constant = CGRectGetMaxY(self.navigationView.frame);
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.textView setContentOffset:CGPointZero];
}

@end
