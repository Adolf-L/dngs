/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNRouteTypeView.m
 *
 * Description  : DNRouteTypeView
 *
 * Author       : eisen
 *
 * History      : Creation, 2018/6/27, Create the file
 *****************************************************************************************
 **/

#import "DNRouteTypeView.h"
#import "DNScrollView.h"
#import "UIImage+GIF.h"
#import "DNSettingGuideView.h"

@interface DNRouteTypeView()<UIScrollViewDelegate>

@property (nonatomic, strong) UIButton       *settingBtn;
@property (nonatomic, strong) UIView         *seletedBgView;
@property (nonatomic, strong) DNScrollView   *typeScrollView;
@property (nonatomic, strong) NSMutableArray *typeBtnArray;
@property (nonatomic, strong) DNSettingGuideView *guideView;

@property (nonatomic, strong) NSArray      *typeArray;
@property (nonatomic, assign) NSInteger    lastTypeIndex;

@end

@implementation DNRouteTypeView

#pragma mark - Life cycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self layoutTypeView];
}

#pragma mark - Public

- (void)refreshTypeView:(DNRouteType)type
{
    CGFloat orginX = 0;
    UIButton *curTypeBtn = nil;
    for (UIButton *typeBtn in self.typeBtnArray) {
        CGFloat width = 58;
        typeBtn.selected = NO;
        
        if (typeBtn.tag == type) {
            width = width + 40;
            curTypeBtn = typeBtn;
        }
        typeBtn.frame = CGRectMake(orginX, 0, width, self.bounds.size.height);
        orginX = CGRectGetMaxX(typeBtn.frame);
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        curTypeBtn.selected = YES;
        self.seletedBgView.center = curTypeBtn.center;
    }];
    if ([self.delegate respondsToSelector:@selector(didChangeType:)]) {
        [self.delegate didChangeType:type];
    }
}

- (void)showGuideGIF
{
    self.guideView = [[DNSettingGuideView alloc] initWithFrame:CGRectMake(0, 0, 48, 40)];
    self.guideView.clipsToBounds = YES;
    [self insertSubview:self.guideView atIndex:0];
    [self.guideView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(self);
        make.width.mas_equalTo(@(48));
    }];
    [self.guideView showAnimation];
}

- (void)removeGuideGIF
{
    [self.guideView stopAnimation];
    [self.guideView removeFromSuperview];
}

#pragma mark - Actions

- (void)actionChangeType:(UIButton *)sender
{
    [self refreshTypeView:sender.tag];
}

- (void)onSettingDetail
{
    [self removeGuideGIF];
    if ([self.delegate respondsToSelector:@selector(onSettingDetail)]) {
        [self.delegate onSettingDetail];
    }
}

#pragma mark - Privates

- (void)layoutTypeView
{
    [self.settingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(self);
        make.width.mas_equalTo(@(48));
    }];
    [self.typeScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.equalTo(self);
        make.right.equalTo(self.settingBtn.mas_left);
    }];
    self.seletedBgView.layer.cornerRadius = 5;
    
    CGFloat orginX = 0;
    CGFloat height = self.bounds.size.height;
    for (int i = 0 ; i<self.typeArray.count ; i++) {
        NSDictionary *typeDic = self.typeArray[i];
        NSString *type = [typeDic valueForKey:@"type"];
        
        CGFloat width = 58;
        if ([type integerValue] == DNRouteTypeCar) {
            width = width + 40;
        }
        NSString *imgName = [NSString stringWithFormat:@"DNFeature.bundle/route_type_%@", type];
        
        UIButton *typeBtn = [[UIButton alloc] initWithFrame:CGRectMake(orginX, 0, width, height)];
        if ([type integerValue] == DNRouteTypeCar) {
            typeBtn.selected = YES;
            self.lastTypeIndex = i;
            self.seletedBgView.center = typeBtn.center;
        }
        typeBtn.tag = [type integerValue];
        [typeBtn setTitle:[typeDic valueForKey:@"name"] forState:UIControlStateNormal];
        [typeBtn setImage:[UIImage imageNamed:imgName] forState:UIControlStateSelected];
        [typeBtn setTitleColor:DNColor9B9B9B forState:UIControlStateNormal];
        [typeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [typeBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 4)];
        [typeBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 4, 0, 0)];
        [typeBtn.titleLabel setFont:DNFont15];
        [typeBtn addTarget:self action:@selector(actionChangeType:) forControlEvents:UIControlEventTouchUpInside];
        [self.typeScrollView addSubview:typeBtn];
        [self.typeBtnArray addObject:typeBtn];
        
        orginX = CGRectGetMaxX(typeBtn.frame);
        if (i == self.typeBtnArray.count - 1) {
            self.typeScrollView.contentSize = CGSizeMake(orginX, height);
        }
    }
}

#pragma mark - Getters

- (UIButton *)settingBtn
{
    if (!_settingBtn) {
        UIImage *image = [UIImage imageNamed:@"DNFeature.bundle/route_type_setting"];
        _settingBtn = [[UIButton alloc] init];
        [_settingBtn setImage:image forState:UIControlStateNormal];
        [_settingBtn addTarget:self
                        action:@selector(onSettingDetail)
              forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_settingBtn];
    }
    return _settingBtn;
}

- (UIView *)seletedBgView
{
    if (!_seletedBgView) {
        _seletedBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 74, 30)];
        _seletedBgView.backgroundColor = DNColor27C411;
        [self.typeScrollView addSubview:_seletedBgView];
    }
    return _seletedBgView;
}

- (UIScrollView *)typeScrollView
{
    if (!_typeScrollView) {
        _typeScrollView = [[DNScrollView alloc] init];
        _typeScrollView.delegate = self;
        _typeScrollView.scrollEnabled = YES;
        _typeScrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_typeScrollView];
    }
    return _typeScrollView;
}

- (NSArray *)typeArray
{
    if (!_typeArray) {
        _typeArray = @[@{@"type": @(DNRouteTypeWalk), @"name": @"步行"},
                       @{@"type": @(DNRouteTypeRide), @"name": @"骑行"},
                       @{@"type": @(DNRouteTypeCar), @"name": @"驾车"},
                       @{@"type": @(DNRouteTypeLine), @"name": @"直线"}];
    }
    return _typeArray;
}

- (NSMutableArray *)typeBtnArray
{
    if (!_typeBtnArray) {
        _typeBtnArray = [NSMutableArray array];
    }
    return _typeBtnArray;
}

@end
