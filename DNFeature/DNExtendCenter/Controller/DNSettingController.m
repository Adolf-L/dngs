//
//  DNSettingController.m
//  DNFeature
//
//  Created by eisen.chen on 2018/9/6.
//

#import "DNSettingController.h"
#import "DNSettingViewCell.h"

@interface DNSettingController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray     *dataList;

@end

@implementation DNSettingController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self layoutSettingView];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"DNSettingViewCellIden";
    DNSettingViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell) {
        UINib* nib = [UINib nibWithNibName:@"DNSettingViewCell" bundle:nil];
        cell = [nib instantiateWithOwner:nil options:nil].lastObject;
        [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
    }
    NSDictionary *dataDic = [self.dataList objectAtIndex:indexPath.row];
    [cell configWithData:dataDic andIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dataDic = [self.dataList objectAtIndex:indexPath.row];
    NSString *routeVC = [dataDic valueForKey:@"routeVC"];
    NSString *url = [NSString stringWithFormat:@"root/push/%@", routeVC];
    [[DNRouteManager sharedInstance] routeURLStr:url];
}

#pragma mark - Privats

- (void)layoutSettingView
{
    self.titleLabel.text = @"设置";
    
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
        _dataList = @[@{@"title": @"关于软件", @"routeVC": @"DNAboutAppController", @"bottomLine": @(YES)},
                      @{@"title": @"联系我们", @"routeVC": @"DNContactController"}];
    }
    return _dataList;
}

@end
