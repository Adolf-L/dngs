//
//  DNHomeGuideController.m
//  DNFeature
//
//  Created by eisen.chen on 2018/9/6.
//

#import "DNHomeGuideController.h"
#import "DNDrawerManager.h"

@interface DNHomeGuideController ()

@end

@implementation DNHomeGuideController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[DNDrawerManager sharedInstance] stopDrawer];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[DNDrawerManager sharedInstance] startDrawer];
}

#pragma mark - Actions

- (IBAction)onBack:(UIButton *)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kReadHomeGuide];
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
