//
//  DNNoticeViewController.m
//  AVOSCloud
//
//  Created by eisen.chen on 2018/12/15.
//

#import "DNNoticeViewController.h"
#import "DNNoticeViewCell.h"

@interface DNNoticeViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel     *promptLabel;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) NSMutableArray *dataList;

@end

@implementation DNNoticeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self layoutContentView];
    [self obtainNoticeData];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DNNoticeViewCell* cell = (DNNoticeViewCell*)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    return [cell obtainCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"DNNoticeViewCellIden";
    DNNoticeViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell) {
        UINib *nib = [UINib nibWithNibName:@"DNNoticeViewCell" bundle:nil];
        cell = [nib instantiateWithOwner:nil options:nil].lastObject;
        [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
    }
    NSDictionary *dataDic = [self.dataList objectAtIndex:indexPath.row];
    [cell configWithData:dataDic andIndexPath:indexPath];
    if (self.indexPath && indexPath.row == self.indexPath.row && indexPath.section == self.indexPath.section) {
        [cell showDetail];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.indexPath && indexPath.row == self.indexPath.row && indexPath.section == self.indexPath.section) {
        self.indexPath = nil;
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        self.indexPath = indexPath;
        [tableView reloadData];
    }
}

#pragma mark - Privats

- (void)layoutContentView
{
    self.titleLabel.text = @"通知中心";
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navigationView.mas_bottom);
        make.left.bottom.right.equalTo(self.view);
    }];
    [self.promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
    [self.tableView reloadData];
}

- (void)obtainNoticeData
{
    NSDictionary *dataDic = [[NSUserDefaults standardUserDefaults] objectForKey:kLocalNoticeList];
    if (dataDic) {
        NSTimeInterval lastTime = [[dataDic valueForKey:@"time"] doubleValue];
        NSTimeInterval curTime  = [[NSDate date] timeIntervalSince1970];
        if (fabs(curTime - lastTime) > (24 * 60 * 60)) {
            [self downloadNoticeList];
        } else {
            self.dataList = [dataDic valueForKey:@"dataList"];
            [self.tableView reloadData];
        }
    } else {
        [self downloadNoticeList];
    }
    self.promptLabel.hidden = (self.dataList.count > 0);
}

- (void)downloadNoticeList
{
    [DNProfileManager sharedInstance].hasNewNotice = NO;
    NSURL *URL = [NSURL URLWithString:@"http://data.daniu.net/ios/dngps_notice"];
    NSData *data = [NSData dataWithContentsOfURL:URL];
    if (!data) {
        return ;
    }
    NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data
                                                        options:NSJSONReadingMutableContainers
                                                          error:nil];
    if (1 == [[dataDic valueForKey:@"status"] intValue]) {
        __weak typeof(self) weakSelf = self;
        NSArray *noticeList = [dataDic valueForKey:@"data"];
        NSString *curVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
        [noticeList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSInteger noticeID = [[obj valueForKey:@"id"] integerValue];
            NSInteger readNoticeID = [[NSUserDefaults standardUserDefaults] integerForKey:kReadNoticeID];
            if (noticeID > readNoticeID) {
                [[NSUserDefaults standardUserDefaults] setInteger:noticeID forKey:kReadNoticeID];
            }
            
            BOOL isExist = NO;
            for (NSDictionary *noticeDic in weakSelf.dataList) {
                if ([[noticeDic valueForKey:@"id"] intValue] == [[obj valueForKey:@"id"] intValue]) {
                    isExist = YES;
                    *stop = YES;
                }
            }
            
            NSArray *whiteList = [obj valueForKey:@"whitelist"];
            if (whiteList.count > 0) {
                BOOL isWhite = NO;
                for (NSString *version in whiteList) {
                    if ([version isEqualToString:curVersion]) {
                        isWhite = YES;
                        break;
                    }
                }
                
                if (!isExist && isWhite) {
                    [weakSelf.dataList insertObject:obj atIndex:0];
                }
            } else {
                BOOL isBlack = NO;
                NSArray *blackList = [obj valueForKey:@"blacklist"];
                for (NSString *version in blackList) {
                    if ([version isEqualToString:curVersion]) {
                        isBlack = YES;
                        break;
                    }
                }
                
                if (!isExist && !isBlack) {
                    [weakSelf.dataList insertObject:obj atIndex:0];
                }
            }
        }];
        [self.tableView reloadData];
        
        NSDictionary *dataDic = @{@"dataList": self.dataList,
                                  @"time": @([[NSDate date] timeIntervalSince1970])};
        [[NSUserDefaults standardUserDefaults] setObject:dataDic forKey:kLocalNoticeList];
    }
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

- (UILabel *)promptLabel
{
    if (!_promptLabel) {
        _promptLabel = [[UILabel alloc] init];
        _promptLabel.font = [UIFont systemFontOfSize:15];
        _promptLabel.text = @"暂时没有新通知！";
        _promptLabel.textColor = DNColor9B9B9B;
        [self.view addSubview:_promptLabel];
    }
    return _promptLabel;
}

- (NSMutableArray *)dataList
{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

@end
