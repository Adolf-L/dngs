/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNCustomSheetView.m
 *
 * Description  : DNCustomSheetView
 *
 * Author       : eisen
 *
 * History      : Creation, 2018/7/21, Create the file
 *****************************************************************************************
 **/

#import "DNCustomSheetView.h"

@interface DNCustomSheetView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray     *itemsArray;

@property (nonatomic, strong) UIView      *backgroudView;
@property (nonatomic, strong) UIView      *contentView;
@property (nonatomic, strong) UIButton    *cancleBtn;
@property (nonatomic, strong) UITableView *itemsTableView;

@end

@implementation DNCustomSheetView

#pragma mark - Life cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self layoutAlertView];
    }
    return self;
}

#pragma mark - Public

- (void)configWithItems:(NSArray *)itemsArray
{
    self.itemsArray = itemsArray;
    
    CGFloat tableViewHeight = self.itemsArray.count * 40;
    if (tableViewHeight > 160) {
        tableViewHeight = 160;
    }
    CGFloat contentViewHeight = tableViewHeight + 50;
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(contentViewHeight));
    }];
    [self.itemsTableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(tableViewHeight));
    }];
    [self.itemsTableView reloadData];
    [UIView animateWithDuration:0.3 animations:^{
        _backgroudView.backgroundColor = [UIColor colorWithHex:0x555555 alpha:0.4];
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self);
        }];
        [self layoutIfNeeded];
    }];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.itemsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* sheetCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                                        reuseIdentifier:@"DNSheetViewCell"];
    sheetCell.detailTextLabel.text = self.itemsArray[indexPath.row];
    sheetCell.detailTextLabel.textAlignment = NSTextAlignmentCenter;
    sheetCell.detailTextLabel.backgroundColor = [UIColor orangeColor];
    return sheetCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(onSelectSheet:)]) {
        [self.delegate onSelectSheet:self.itemsArray[indexPath.row]];
    }
    [self hideSheetView];
}

#pragma mark - Privates

- (void)layoutAlertView
{
    [self.backgroudView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.equalTo(self).offset(160);
        make.height.mas_equalTo(@(160));
    }];
    [self.cancleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(5);
        make.bottom.right.equalTo(self.contentView).offset(-5);
        make.height.mas_equalTo(@(40));
    }];
    [self.itemsTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(5);
        make.bottom.equalTo(self.cancleBtn.mas_top).offset(-5);
        make.right.equalTo(self.contentView).offset(-5);
        make.height.mas_equalTo(80);
    }];
    [self layoutIfNeeded];
}

- (void)onCancel
{
    if ([self.delegate respondsToSelector:@selector(onSelectSheet:)]) {
        [self.delegate onSelectSheet:@"取消"];
    }
    [self hideSheetView];
}

- (void)hideSheetView
{
    [UIView animateWithDuration:0.3 animations:^{
        _backgroudView.backgroundColor = [UIColor colorWithHex:0x555555 alpha:0];
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(160);
        }];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - Getters

- (UIView *)backgroudView
{
    if (!_backgroudView) {
        _backgroudView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _backgroudView.backgroundColor = [UIColor colorWithHex:0x555555 alpha:0];
        [self addSubview:_backgroudView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(hideSheetView)];
        [_backgroudView addGestureRecognizer:tapGesture];
    }
    return _backgroudView;
}

- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor clearColor];
        [self addSubview:_contentView];
    }
    return _contentView;
}

- (UIButton *)cancleBtn
{
    if (!_cancleBtn) {
        _cancleBtn = [[UIButton alloc] init];
        _cancleBtn.backgroundColor = [UIColor whiteColor];
        _cancleBtn.layer.cornerRadius = 10;
        [_cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancleBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_cancleBtn.titleLabel setFont:DNFont15];
        [_cancleBtn addTarget:self action:@selector(onCancel) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:_cancleBtn];
    }
    return _cancleBtn;
}

- (UITableView *)itemsTableView
{
    if (!_itemsTableView) {
        _itemsTableView = [[UITableView alloc] init];
        _itemsTableView.backgroundColor = [UIColor whiteColor];
        _itemsTableView.delegate = self;
        _itemsTableView.dataSource = self;
        _itemsTableView.layer.cornerRadius = 10;
        [_contentView addSubview:_itemsTableView];
    }
    return _itemsTableView;
}

@end
