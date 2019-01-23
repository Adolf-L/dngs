//
//  DNRouteGuideController.m
//  DNFeature
//
//  Created by eisen.chen on 2018/9/6.
//

#import "DNRouteGuideController.h"

@interface DNRouteGuideController ()

@end

@implementation DNRouteGuideController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - Actions

- (IBAction)onBack:(UIButton *)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kReadRouteGuide];
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
