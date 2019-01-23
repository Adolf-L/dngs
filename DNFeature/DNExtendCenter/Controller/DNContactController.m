//
//  DNContactController.m
//  DNFeature
//
//  Created by eisen.chen on 2018/8/28.
//

#import "DNContactController.h"
#import "DNContactCell.h"

@interface DNContactController() <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *contactTableView;
@property (nonatomic, strong) NSArray *dataList;

@end

@implementation DNContactController

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titleLabel.text = @"联系我们";
    [self layoutContactView];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"DNContactCellIden";
    
    NSDictionary *dataInfo = [self.dataList objectAtIndex:indexPath.row];
    DNContactCell *contactCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == contactCell) {
        UINib* nib = [UINib nibWithNibName:@"DNContactCell" bundle:nil];
        contactCell = [nib instantiateWithOwner:nil options:nil].lastObject;
        [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
    }
    contactCell.selectionStyle = UITableViewCellSelectionStyleNone;
    [contactCell configWithData:dataInfo];
    return contactCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Privates

- (void)layoutContactView
{
    [self.contactTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navigationView.mas_bottom);
        make.left.bottom.right.equalTo(self.view);
    }];
    [self.contactTableView reloadData];
    [self.view layoutIfNeeded];
}

#pragma mark - Getters

- (UITableView *)contactTableView
{
    if (!_contactTableView) {
        _contactTableView = [[UITableView alloc] init];
        _contactTableView.backgroundColor = DNColorF6F6F6;
        _contactTableView.delegate = self;
        _contactTableView.dataSource = self;
        _contactTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_contactTableView];
    }
    return _contactTableView;
}

- (NSArray *)dataList
{
    if (!_dataList) {
        _dataList = @[@{@"title": @"企业客服QQ: 800186200", @"des": @"工作日09:30 - 19:30"},
                      @{@"title": @"企业客服微信: Daniukefu02", @"des": @"工作日09:30 - 19:30"},
                      @{@"title": @"代理申请微信: Daniukefu01", @"des": @"24小时不定时在线"},
                      @{@"title": @"投诉反馈邮箱: kefu@daniu.net", @"des": @"服务投诉、重大BUG反馈、合作意向"},
                      @{@"title": @"大牛官网: www.daniu.net", @"des": @"最新版本安装包和消息"}];
    }
    return _dataList;
}

@end
