//
//  DNRouteCollectionController.m
//  DNFeature
//
//  Created by eisen.chen on 2018/9/5.
//

#import "DNRouteCollectionController.h"
#import "DNRouteModel.h"
#import "DNEditLineName.h"
#import "DNCollectionUnit.h"
#import "DNRouteCollectionCell.h"

@interface DNRouteCollectionController ()<UITableViewDelegate, UITableViewDataSource, DNRouteCollectionCellDelegate>

@property (nonatomic, strong) UILabel     *promptLabel;
@property (nonatomic, strong) UITableView *collectionTable;
@property (nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic, strong) DNEditLineName *editView;

@property (nonatomic, strong) NSMutableDictionary *cellFactory;

@end

@implementation DNRouteCollectionController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self layoutCollectionView];
}

#pragma mark - DNRouteCollectionCellDelegate

- (void)onRefreshCollection
{
    [self.collectionTable reloadData];
}

- (void)onSelectPath:(NSIndexPath *)indexPath
{
    NSDictionary *dataDic = [self.dataList objectAtIndex:indexPath.row];
    NSString *bundleID = [dataDic valueForKey:@"bundleID"];
    [DNAlertView showAlert:@"确认添加当前路线到选点设置页面？"
                   message:nil
                firstTitle:@"取消"
               firstAction:nil
               secondTitle:@"确认"
              secondAction:^{
                  NSDictionary *userInfo = @{@"bundleID": bundleID};
                  [[NSNotificationCenter defaultCenter] postNotificationName:kSelectRoutPath
                                                                      object:nil
                                                                    userInfo:userInfo];
                  [self.navigationController popViewControllerAnimated:YES];
              }];
}

- (void)onEditNameWithIndexPath:(NSIndexPath *)indexPath andFrame:(CGRect)frame
{
    if (!self.editView || self.editView.hidden == YES) {
        UINib *nib = [UINib nibWithNibName:@"DNEditLineName" bundle:nil];
        self.editView = [[nib instantiateWithOwner:self options:nil] lastObject];
        self.editView.frame = [UIScreen mainScreen].bounds;
        
        __weak typeof(self) weakSelf = self;
        self.editView.callBack = ^(id result) {
            NSDictionary *dic = weakSelf.dataList[indexPath.row];
            NSMutableDictionary *newDic = [NSMutableDictionary dictionaryWithDictionary:dic];
            [newDic setValue:result forKey:@"name"];
            weakSelf.dataList[indexPath.row] = newDic;
            [weakSelf.collectionTable reloadData];
            [DNCollectionUnit updateCollectRoute:[dic valueForKey:@"bundleID"] withName:result];
        };
        [self.view addSubview:self.editView];
        [self.editView setContentFrame:frame];
    }
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DNRouteCollectionCell* cell = [self.cellFactory valueForKey:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];
    CGFloat height = [cell obtainCellHeight];
    return height > 0 ? height : 113;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"DNRouteCollectionCellIden";
    DNRouteCollectionCell* collectionCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == collectionCell) {
        UINib* nib = [UINib nibWithNibName:@"DNRouteCollectionCell" bundle:nil];
        collectionCell = [nib instantiateWithOwner:nil options:nil].lastObject;
        [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
    }
    collectionCell.delegate = self;
    NSDictionary *dataDic = [self.dataList objectAtIndex:indexPath.row];
    [collectionCell configWithData:dataDic andIndexPath:indexPath];
    [self.cellFactory setValue:collectionCell forKey:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];
    return collectionCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete: {
            NSDictionary *dataDic = [self.dataList objectAtIndex:indexPath.row];
            if ([DNCollectionUnit deleteCollectRoute:[dataDic valueForKey:@"bundleID"]]) {
                [self.dataList removeObjectAtIndex:indexPath.row];
                [tableView beginUpdates];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                [tableView endUpdates];
            } else {
                [DNPromptView showToast:@"删除当前路线出现异常！"];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - Privats

- (void)layoutCollectionView
{
    self.titleLabel.text = @"收藏路线";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
    [self.collectionTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navigationView.mas_bottom);
        make.left.bottom.right.equalTo(self.view);
    }];
    
    if (self.dataList.count < 1) {
        self.collectionTable.hidden = YES;
    }
}

#pragma mark - Getters

- (UILabel *)promptLabel
{
    if (!_promptLabel) {
        _promptLabel = [[UILabel alloc] init];
        _promptLabel.font = DNFont16;
        _promptLabel.textColor = DNColor9B9B9B;
        _promptLabel.text = @"暂无收藏路线";
        _promptLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_promptLabel];
    }
    return _promptLabel;
}

- (UITableView *)collectionTable
{
    if (!_collectionTable) {
        _collectionTable = [[UITableView alloc] init];
        _collectionTable.delegate = self;
        _collectionTable.dataSource = self;
        _collectionTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_collectionTable];
    }
    return _collectionTable;
}

- (NSMutableArray *)dataList
{
    if (!_dataList) {
        NSMutableArray *tmpArray = [NSMutableArray array];
        NSArray *collectionArray = [[NSUserDefaults standardUserDefaults] objectForKey:kRouteLineCollection];
        [collectionArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *bundleID = [obj valueForKey:@"bundleID"];
            DNRouteModel *routeModel = [[[DNFmdbUnit sharedInstance] dnSearchModel:[DNRouteModel class]
                                                                             withKey:@"bundleID"
                                                                            andValue:bundleID] firstObject];
            NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithDictionary:obj];
            [infoDic setValue:routeModel.keyPoints forKey:@"keyPoints"];
            [tmpArray addObject:infoDic];
        }];
        _dataList = tmpArray;
    }
    return _dataList;
}

- (NSMutableDictionary *)cellFactory
{
    if (!_cellFactory) {
        _cellFactory = [NSMutableDictionary dictionary];
    }
    return _cellFactory;
}

@end
