//
//  DNFamilyController.m
//  DNFeature
//
//  Created by eisen.chen on 2018/9/5.
//

#import "DNFamilyController.h"
#import "AVCloud.h"
#import "DNFamilyViewCell.h"
#import "DNProfileManager.h"

@interface DNFamilyController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *familyTableView;
@property (nonatomic, strong) NSArray *dataList;

@end

@implementation DNFamilyController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self layoutFamilyView];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 156;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"DNFamilyViewCellIden";
    DNFamilyViewCell* familyCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == familyCell) {
        UINib* nib = [UINib nibWithNibName:@"DNFamilyViewCell" bundle:nil];
        familyCell = [nib instantiateWithOwner:nil options:nil].lastObject;
        [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
    }
    NSDictionary *dataDic = [self.dataList objectAtIndex:indexPath.row];
    [familyCell configWithData:dataDic andIndexPath:indexPath];
    return familyCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dataDic = [self.dataList objectAtIndex:indexPath.row];
    NSString *leftUrl = [dataDic valueForKey:@"leftUrl"];
    if (leftUrl) {
        [[DNRouteManager sharedInstance] gotoWebsite:leftUrl];
    }
}

#pragma mark - Privats

- (void)layoutFamilyView
{
    self.titleLabel.text = @"大牛家族";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.familyTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navigationView.mas_bottom);
        make.left.bottom.right.equalTo(self.view);
    }];
    
    [self obtainFamilyData];
}

- (void)obtainFamilyData
{
    NSDictionary *dataDic = [[NSUserDefaults standardUserDefaults] objectForKey:kDaniuFamilyData];
    if (!dataDic) {
        NSArray *defaultArray = @[
                                  @{@"imgUrl": @"family_item_daniu_helper",
                                    @"appName": @"大牛助手",
                                    @"subTitle": @"",
                                    @"intro": @"支持多开APP、数据模拟、插件安装，让您的手机功能得到扩展，增加更多玩机乐趣。",
                                    @"leftText": @"去官网下载",
                                    @"leftUrl": @"http://www.daniu.net/daniuzhushou.html",
                                    @"system": @(0)},
                                  @{@"imgUrl": @"family_item_daniu_android",
                                    @"appName": @"Daniu大牛",
                                    @"subTitle": @"安卓ROOT版",
                                    @"intro": @"“Daniu大牛”是在ROOT环境下运行的APP，拥有位置模拟、APP防检测、WiFi模拟、WiFi密码查看等功能。",
                                    @"leftText": @"去官网下载",
                                    @"leftUrl": @"http://www.daniu.net/daniu-root.html",
                                    @"system": @(0)},
                                  @{@"imgUrl": @"family_item_daniu_ios",
                                    @"appName": @"Daniu大牛",
                                    @"subTitle": @"苹果越狱版",
                                    @"intro": @"“Daniu大牛”是在越狱环境下运行的APP，拥有位置模拟、运动模拟、拍照模拟、WiFi模拟、WiFi密码查看等功能。",
                                    @"leftText": @"安装教程",
                                    @"leftUrl": @"http://www.daniu.net/daniu-yueyu.html",
                                    @"system": @(1)},
                                  @{@"imgUrl": @"family_item_daniu_gps",
                                    @"appName": @"大牛GPS",
                                    @"subTitle": @"",
                                    @"intro": @"适用于iOS8以上的苹果设备，支持位置模拟和路线模拟。",
                                    @"leftText": @"去官网查看",
                                    @"leftUrl": @"http://www.daniu.net/daniugps.html",
                                    @"system": @(1)}];
        self.dataList = defaultArray;
        [self.familyTableView reloadData];
        
        NSDictionary *dataDic = @{@"dataList": defaultArray};
        [[NSUserDefaults standardUserDefaults] setObject:dataDic forKey:kDaniuFamilyData];
    } else {
        NSTimeInterval lastTime = [[dataDic valueForKey:@"time"] doubleValue];
        NSTimeInterval curTime  = [[NSDate date] timeIntervalSince1970];
        if ([DNProfileManager sharedInstance].hasNewFamily && fabs(curTime - lastTime) > (4 * 24 * 60 * 60)) {
            [self downloadFamilyList];
        } else {
            self.dataList = [dataDic valueForKey:@"dataList"];
            [self.familyTableView reloadData];
        }
    }
}

- (void)downloadFamilyList
{
    __weak typeof(self) weakSelf = self;
    NSDictionary *paramsDic = @{@"bundleId": [[NSBundle mainBundle] bundleIdentifier]};
    [AVCloud callFunctionInBackground:LCGetFamilyList withParameters:paramsDic block:^(id object, NSError *error) {
        if (error) {
            return ;
        }
        
        NSData *jsonData = [object dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        weakSelf.dataList = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&err];
        [weakSelf.familyTableView reloadData];
        
        NSDictionary *dataDic = @{@"dataList": weakSelf.dataList,
                                  @"time": @([[NSDate date] timeIntervalSince1970])};
        [[NSUserDefaults standardUserDefaults] setObject:dataDic forKey:kDaniuFamilyData];
    }];
}

#pragma mark - Getters

- (UITableView *)familyTableView
{
    if (!_familyTableView) {
        _familyTableView = [[UITableView alloc] init];
        _familyTableView.backgroundColor = DNColorF6F6F6;
        _familyTableView.delegate = self;
        _familyTableView.dataSource = self;
        _familyTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_familyTableView];
    }
    return _familyTableView;
}

@end
