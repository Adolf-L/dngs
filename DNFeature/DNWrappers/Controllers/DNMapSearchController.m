/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNMapSearchController.m
 *
 * Description  : DNMapSearchController
 *
 * Author       : eisen
 *
 * History      : Creation, 2017/2/7, Create the file
 *****************************************************************************************
 **/

#import "DNMapSearchController.h"
#import "DNSearchTableViewCell.h"
#import "DNFormatGps.h"
#import "BMKPoiSearch.h"
#import "BMKSuggestionSearch.h"

@interface DNMapSearchController ()<UISearchBarDelegate, UITableViewDataSource,
                                    UITableViewDelegate, BMKPoiSearchDelegate, BMKSuggestionSearchDelegate>

@property (nonatomic, strong) BMKPoiSearch              *poiSearch;         //搜索基类
@property (nonatomic, strong) BMKSuggestionSearch       *sugSearch;         //sug搜索业务
@property (nonatomic, strong) BMKSuggestionSearchOption *sugSearchOption;   //sug搜索业务配置

@property (nonatomic, strong) UIView         *navView;
@property (nonatomic, strong) UISearchBar    *searchBar;//搜索框
@property (nonatomic, strong) UITableView    *tableView;//tableview
@property (nonatomic, strong) NSMutableArray *dataArray;//数据源

@end

@implementation DNMapSearchController

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self layoutSearchView];
    [self obtainHistoryRecord];
}

- (void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
    
    if (@available(iOS 11, *)) {
        UIEdgeInsets safeEdge = self.view.safeAreaInsets;
        [self.navView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(safeEdge.top);
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}

#pragma mark - Actions

- (void)actionBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)actionCleanHistoryRecord
{
    __weak typeof(self) weakSelf = self;
    [DNAlertView showAlert:@"确认清空历史记录？"
                   message:nil
                firstTitle:@"取消"
               firstAction:nil
               secondTitle:@"确认"
              secondAction:^(UIAlertAction * _Nullable action) {
                  [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"history"];
                  
                  [weakSelf.dataArray removeAllObjects];
                  [weakSelf.tableView reloadData];
                  weakSelf.tableView.tableFooterView = nil;
              }];
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [searchBar resignFirstResponder];
    }
    
    if ([searchBar.text isEqualToString:kShowLogView]) {
        NSDictionary *dic = @{@"CMD": kShowLogView};
        [[NSNotificationCenter defaultCenter] postNotificationName:SelectSearchPoint
                                                            object:nil
                                                          userInfo:dic];
        [self.navigationController popViewControllerAnimated:YES];
    }
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length > 0) {
        [self.dataArray removeAllObjects];
        [self.tableView reloadData];
        self.tableView.tableFooterView = nil;

        self.sugSearchOption.keyword = searchBar.text;
        [self.sugSearch suggestionSearch:self.sugSearchOption];
    } else {//删除文本时
        [self.dataArray removeAllObjects];
        [self obtainHistoryRecord];
    }
}

#pragma mark - BMKSuggestionSearchDelegate
//返回搜索的结果
- (void)onGetSuggestionResult:(BMKSuggestionSearch *)searcher result:(BMKSuggestionSearchResult *)result errorCode:(BMKSearchErrorCode)error
{
    if (error != BMK_SEARCH_NO_ERROR) {
        return;
    }
    
    [self.dataArray removeAllObjects];
    for (int i = 0; i < result.suggestionList.count; i++) {
        BMKSuggestionInfo *sugInfo = result.suggestionList[i];
        NSMutableDictionary *pointDic = [NSMutableDictionary dictionary];
        if (sugInfo.key) {
            [pointDic setValue:sugInfo.key forKey:@"key"];
        }
        if (sugInfo.city) {
            [pointDic setValue:sugInfo.city forKey:@"city"];
        }
        if (sugInfo.district) {
            [pointDic setValue:sugInfo.district forKey:@"district"];
        }
        [pointDic setValue:@(sugInfo.location.latitude) forKey:@"latitude"];
        [pointDic setValue:@(sugInfo.location.longitude) forKey:@"longitude"];
        [self.dataArray addObject:pointDic];
    }
    [self refreshTableView];
}

#pragma mark - tableView delegate

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"DNSearchTableViewCellIden";
    DNSearchTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        UINib* nib = [UINib nibWithNibName:@"DNSearchTableViewCell" bundle:nil];
        cell = [nib instantiateWithOwner:nil options:nil].lastObject;
        [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
    }
    NSDictionary *pointDic = self.dataArray[indexPath.row];
    cell.neirongLab.text= [pointDic valueForKey:@"key"];
    
    cell.weizhiLab.text= @"";
    NSString *city = [pointDic valueForKey:@"city"];
    NSString *district = [pointDic valueForKey:@"district"];
    if (city && district) {
        cell.weizhiLab.text = [NSString stringWithFormat:@"%@%@", city, district];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *pointDic = self.dataArray[indexPath.row];
    
    __block BOOL isExist = NO;
    NSArray *array = [[NSUserDefaults standardUserDefaults] arrayForKey:@"history"];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([[obj valueForKey:@"key"] isEqualToString:[pointDic valueForKey:@"key"]]) {
            isExist = YES;
            *stop = YES;
        }
    }];
    if (!isExist) {
        NSMutableArray *newArray = [NSMutableArray arrayWithArray:array];
        [newArray insertObject:pointDic atIndex:0];
        [[NSUserDefaults standardUserDefaults] setObject:newArray forKey:@"history"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SelectSearchPoint
                                                        object:nil
                                                      userInfo:pointDic];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Privates

- (void)layoutSearchView
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *cancelBtn = [[UIButton alloc] init];
    [cancelBtn setImage:[UIImage imageNamed:@"DNFeature.bundle/nav_back"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(actionBack) forControlEvents:UIControlEventTouchDown];
    [self.navView addSubview:cancelBtn];
    
    CALayer *lineLayer = [CALayer layer];
    CGFloat screenWidth = [UIScreen mainScreen ].bounds.size.width;
    lineLayer.frame = CGRectMake(0, 44-1/[UIScreen mainScreen].scale, screenWidth, 1/[UIScreen mainScreen].scale);
    lineLayer.backgroundColor = DNColorD6D6D6.CGColor;
    [self.navView.layer addSublayer:lineLayer];
    
    [self.navView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(20);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(@(44));
    }];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.equalTo(self.navView);
        make.width.mas_equalTo(@(50));
    }];
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cancelBtn.mas_right);
        make.right.equalTo(self.view).offset(-15);
        make.centerY.equalTo(cancelBtn.mas_centerY);
        make.height.mas_equalTo(@(42));
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navView.mas_bottom);
        make.left.bottom.right.equalTo(self.view);
    }];
    [self.view layoutIfNeeded];
}

- (void)refreshTableView
{
    if (self.dataArray.count && !self.tableView.tableFooterView) {
        UIButton* footBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [footBtn setTitle:@"清空历史记录" forState:UIControlStateNormal];
        [footBtn setTitleColor:DNColor9B9B9B forState:UIControlStateNormal];
        [footBtn addTarget:self action:@selector(actionCleanHistoryRecord) forControlEvents:UIControlEventTouchUpInside];
        footBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        footBtn.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60);
        self.tableView.tableFooterView = footBtn;
    }
    [self.tableView reloadData];
}

- (void)obtainHistoryRecord
{
    NSArray *array = [[NSUserDefaults standardUserDefaults] arrayForKey:@"history"];
    if (array.count > 0 && ![array[0] valueForKey:@"key"]) {
        array = nil;
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"history"];
    }
    self.dataArray = [NSMutableArray arrayWithArray:array];
    [self refreshTableView];
}

#pragma mark - Getters

- (UIView *)navView
{
    if (!_navView) {
        _navView = [[UIView alloc] init];
        _navView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_navView];
    }
    return _navView;
}

- (UISearchBar *)searchBar
{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] init];
        UITextField *searchField = [_searchBar valueForKey:@"searchField"];
        if (searchField) {
            [searchField setBackgroundColor:[UIColor whiteColor]];
            searchField.layer.cornerRadius = 6.0f;
            searchField.layer.borderColor = DNColorD6D6D6.CGColor;
            searchField.layer.borderWidth = 1/[UIScreen mainScreen].scale;
            searchField.layer.masksToBounds = YES;
        }
        _searchBar.backgroundImage = [[UIImage alloc] init];
        _searchBar.delegate = self;
        _searchBar.placeholder = @"请输入搜索内容";
        [_searchBar becomeFirstResponder];
        [self.navView addSubview:_searchBar];
    }
    return _searchBar;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (BMKPoiSearch *)poiSearch
{
    if (_poiSearch) {
        _poiSearch = [[BMKPoiSearch alloc] init];
        _poiSearch.delegate = self;
    }
    return _poiSearch;
}

- (BMKSuggestionSearch *)sugSearch
{
    if (!_sugSearch) {
        _sugSearch = [[BMKSuggestionSearch alloc] init];
        _sugSearch.delegate = self;
    }
    return _sugSearch;
}

- (BMKSuggestionSearchOption *)sugSearchOption
{
    if (!_sugSearchOption) {
        _sugSearchOption = [[BMKSuggestionSearchOption alloc] init];
        _sugSearchOption.cityname = @"北京";
    }
    return _sugSearchOption;
}


@end
