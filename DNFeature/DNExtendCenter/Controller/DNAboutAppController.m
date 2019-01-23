//
//  DNAboutAppController.m
//  DNFeature
//
//  Created by eisen.chen on 2018/9/6.
//

#import "DNAboutAppController.h"
#import "DNSettingViewCell.h"

@interface DNAboutAppController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray     *dataList;

@end

@implementation DNAboutAppController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self layoutAboutAppView];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dataDic = [self.dataList objectAtIndex:indexPath.row];
    if ([[dataDic valueForKey:@"blank"] boolValue]) {
        return 20;
    } else {
        return 50;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dataDic = [self.dataList objectAtIndex:indexPath.row];
    if ([[dataDic valueForKey:@"blank"] boolValue]) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        cell.backgroundColor = DNColorF6F6F6;
        return cell;
    } else {
        static NSString *cellIdentifier = @"DNSettingViewCellIden";
        DNSettingViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (nil == cell) {
            UINib* nib = [UINib nibWithNibName:@"DNSettingViewCell" bundle:nil];
            cell = [nib instantiateWithOwner:nil options:nil].lastObject;
            [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
        }
        [cell configWithData:dataDic andIndexPath:indexPath];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dataDic = [self.dataList objectAtIndex:indexPath.row];
    NSString *routeVC = [dataDic valueForKey:@"routeVC"];
    if (routeVC) {
        NSString *url = [NSString stringWithFormat:@"root/push/%@", routeVC];
        [[DNRouteManager sharedInstance] routeURLStr:url];
    }
    BOOL appStore = [[dataDic valueForKey:@"appStore"] boolValue];
    if (appStore) {
        NSString *url = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@", kAppStoreID];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

#pragma mark - Privats

- (void)layoutAboutAppView
{
    self.titleLabel.text = @"关于软件";
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navigationView.mas_bottom);
        make.left.bottom.right.equalTo(self.view);
    }];
    [self.tableView reloadData];
}

#pragma mark - Getters

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = DNColorF6F6F6;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (NSArray *)dataList
{
    if (!_dataList) {
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        version = [NSString stringWithFormat:@"v%@", version];
        _dataList = @[@{@"title": @"大牛GPS", @"value": version, @"bottomLine": @(YES)},
                      @{@"title": @"使用条款和隐私政策", @"routeVC": @"DNPrivacyPolicyController"}];
    }
    return _dataList;
}

@end
