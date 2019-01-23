//
//  DNExtendCenterController.m
//  DNFeature
//
//  Created by eisen.chen on 2018/9/4.
//

#import "DNExtendCenterController.h"
#import "DNShareView.h"
#import "UIView+Gradient.h"
#import "DNExtendCenterCell.h"
#import "DNHomeViewController.h"
#import "UIViewController+MMDrawerController.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width

@interface DNExtendCenterController ()<UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UIView *extendView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *extendViewLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *websiteBtnBottom;


@property (nonatomic, strong) NSArray *dataList;

@end

@implementation DNExtendCenterController

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = DNColorD9D9D9;
    self.navigationController.navigationBarHidden = YES;
    
    NSString *version = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    self.versionLabel.text = [NSString stringWithFormat:@"v %@", version];
    
    [self.headerView setGradientBackgroundWithColors:@[DNColor1D1D1D, DNColor5C5C5C] locations:nil startPoint:CGPointMake(0, 0) endPoint:CGPointMake(0, 1)];
}

- (void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
    
    if (@available(iOS 11, *)) {
        UIEdgeInsets safeEdge = self.view.safeAreaInsets;
        self.headerViewHeight.constant += safeEdge.top;
        self.websiteBtnBottom.constant = safeEdge.bottom;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.dataList = @[@{@"leftImg": @"extend_item_setting", @"title": @"设置"},
                      @{@"leftImg": @"extend_item_news", @"title": @"通知"},
                      @{@"leftImg": @"extend_item_family", @"title": @"大牛家族"},
                      @{@"leftImg": @"extend_item_share", @"title": @"分享软件"}];
    [self.tableView reloadData];
}

#pragma mark - Actions

- (IBAction)gotoWebsite:(UIButton *)sender
{    
    [[DNRouteManager sharedInstance] gotoWebsite:@"http://www.daniu.net"];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return YES;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"DNExtendCenterCellIden";
    DNExtendCenterCell* extendCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == extendCell) {
        UINib* nib = [UINib nibWithNibName:@"DNExtendCenterCell" bundle:nil];
        extendCell = [nib instantiateWithOwner:nil options:nil].lastObject;
        [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
    }
    NSDictionary *dataDic = [self.dataList objectAtIndex:indexPath.row];
    [extendCell configWithData:dataDic andIndexPath:indexPath];
    return extendCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dataDic = [self.dataList objectAtIndex:indexPath.row];
    NSDictionary *userInfo = @{@"title": [dataDic valueForKey:@"title"]};
    [[NSNotificationCenter defaultCenter] postNotificationName:kSelectExtendCenter
                                                        object:nil
                                                      userInfo:userInfo];
}

@end
