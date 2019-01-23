/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNRoutePathView.m
 *
 * Description  : DNRoutePathView
 *
 * Author       : eisen
 *
 * History      : Creation, 2018/6/27, Create the file
 *****************************************************************************************
 **/

#import "DNRoutePathView.h"
#import "DNRoutePathCell.h"

@interface DNRoutePathView()<UITableViewDelegate, UITableViewDataSource, DNRoutePathCellDelegate>

@property (nonatomic, strong) UIButton    *editPathBtn;
@property (nonatomic, strong) UITableView *pathTableView;
@property (nonatomic, strong) UIImageView *blankImgView;

@property (nonatomic, assign) BOOL           packupDetail;
@property (nonatomic, assign) BOOL           didEdited;
@property (nonatomic, strong) NSMutableArray *pathPointArray;

@end

@implementation DNRoutePathView

#pragma mark - Life cycle

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self layoutPathView];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(handleLongPress)];
    [self.pathTableView addGestureRecognizer:longPress];
}

- (void)handleLongPress
{
    if (self.showFold || self.isEditing) {
        return;
    }
    
    if (self.pathPointArray.count < 3) {
        [DNPromptView showToast:@"途径点少于两个无法进入编辑模式"];
    } else {
        self.isEditing = YES;
        [self handleEditPath];
    }
}

#pragma mark - Publics

- (void)configWithPoints:(NSArray *)points
{
    BOOL scrollToBottom = self.pathPointArray.count != points.count;
    BOOL showInsertAnimate = (points.count - self.pathPointArray.count == 1 && points.count < 5);
    
    self.pathPointArray = [NSMutableArray arrayWithArray:points];
    if (showInsertAnimate) {
        NSIndexPath *lastRow = [NSIndexPath indexPathForRow:self.pathPointArray.count-2 inSection:0];
        NSIndexPath *currentRow = [NSIndexPath indexPathForRow:self.pathPointArray.count-1 inSection:0];
        [self.pathTableView beginUpdates];
        [self.pathTableView reloadRowsAtIndexPaths:@[lastRow] withRowAnimation:UITableViewRowAnimationNone];
        [self.pathTableView insertRowsAtIndexPaths:@[currentRow] withRowAnimation:UITableViewRowAnimationRight];
        [self.pathTableView endUpdates];
    } else {
        [self.pathTableView reloadData];
    }
    [self.pathTableView layoutIfNeeded];
    
    CGFloat toping = (self.frame.size.height - points.count*kPathCellHeight)/2;
    toping = toping > 0 ? toping : 0;
    if (!self.showFold) {
        [self.pathTableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(toping);
        }];
    }
    
    if ((points.count > 3 && scrollToBottom) || self.showFold) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.pathPointArray.count-1 inSection:0];
        [self.pathTableView scrollToRowAtIndexPath:indexPath
                                  atScrollPosition:UITableViewScrollPositionBottom
                                          animated:!self.showFold];
    }
}

- (void)showFoldView:(NSArray *)points
{
    self.showFold = YES;
    self.blankImgView.hidden = NO;
    self.pathTableView.scrollEnabled = NO;
    NSMutableDictionary *lastPoint = [NSMutableDictionary dictionaryWithDictionary:points[points.count-1]];
    [lastPoint setValue:@(points.count) forKey:@"index"];
    NSArray *tmpArray = @[points[0], lastPoint];
    [self configWithPoints:tmpArray];
}

- (void)closeFoldView
{
    self.showFold = NO;
    self.editPathBtn.selected = NO;
    self.blankImgView.hidden = YES;
    self.pathTableView.scrollEnabled = YES;
}

- (void)stopEditPoints
{
    [self onEditRoutePath:self.editPathBtn];
}

- (void)setStartPoint:(CLLocationCoordinate2D)startPoint
{
    if (startPoint.latitude != 0) {
        self.pathPointArray[0] = @{@"latitude": @(startPoint.latitude),
                                   @"longitude": @(startPoint.longitude),
                                   @"address": @"我的位置"};
        [self.pathTableView reloadData];
        [self.pathTableView layoutIfNeeded];
    }
}

- (void)packDetailView
{
    self.packupDetail = YES;
    [self.pathTableView reloadData];
    [self.pathTableView layoutIfNeeded];
}

#pragma mark - Actions

- (void)onEditRoutePath:(UIButton *)sender
{
//    if (self.showFold) {
//        // 重新选点
//        if ([self.delegate respondsToSelector:@selector(onSelectPoint)]) {
//            [self.delegate onSelectPoint];
//        }
//    } else {
//        // 编辑或完成编辑现有的选点
//        if (!sender.selected && self.pathPointArray.count < 3) {
//            [DNPromptView showToast:@"途径点少于两个无法进入编辑模式"];
//        } else {
//            sender.selected = !sender.selected;
//            self.isEditing = sender.selected;
//            [self handleEditPath];
//        }
//
//    }
    if (self.showFold) {
        // 重新选点
        if ([self.delegate respondsToSelector:@selector(onSelectPoint)]) {
            [self.delegate onSelectPoint];
        }
    } else {
        if (self.isEditing) {
            // 完成编辑后，需要刷新数据内容
            self.isEditing = NO;
            [self handleEditPath];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.pathTableView reloadData];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.pathPointArray.count-1 inSection:0];
                [self.pathTableView scrollToRowAtIndexPath:indexPath
                                          atScrollPosition:UITableViewScrollPositionBottom
                                                  animated:!self.showFold];
            });
        } else {
            if (!sender.selected && self.pathPointArray.count < 3) {
                [DNPromptView showToast:@"路线规划至少需要两个途径点"];
            } else {
                sender.selected = !sender.selected;
                if ([self.delegate respondsToSelector:@selector(onFinishSelecting)]) {
                    [self.delegate onFinishSelecting];
                }
            }
        }
        
    }
}

- (void)handleEditPath
{
    if (self.isEditing) {
        // 最后一个点是临时的，所以在编辑时要排除在外
        [self.pathPointArray removeLastObject];
        [self.pathTableView reloadData];
    }
    if ([self.delegate respondsToSelector:@selector(onEditPoints:withChange:)]) {
        [self.delegate onEditPoints:self.pathPointArray withChange:self.didEdited];
    }
    [self.pathTableView setEditing:self.isEditing animated:YES];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.pathPointArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *pointDic = [self.pathPointArray objectAtIndex:indexPath.row];
    if ([[pointDic valueForKey:@"blank"] boolValue]) {
        return 8;
    } else {
        return kPathCellHeight;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *pointDic = [self.pathPointArray objectAtIndex:indexPath.row];
    if ([[pointDic valueForKey:@"blank"] boolValue]) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(23, 0, 6, 8)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = [UIImage imageNamed:@"DNFeature.bundle/route_path_blank"];
        [cell addSubview:imageView];
        return cell;
    } else {
        static NSString *cellIdentifier = @"DNRoutePathCellIden";
        DNRoutePathCell* pathCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (nil == pathCell) {
            UINib* nib = [UINib nibWithNibName:@"DNRoutePathCell" bundle:nil];
            pathCell = [nib instantiateWithOwner:nil options:nil].lastObject;
            [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
        }
        pathCell.delegate = self;
        
        BOOL isLastRow = NO;
        if (!self.showFold && !self.isEditing &&
            self.pathPointArray.count > 1 && indexPath.row == self.pathPointArray.count-1) {
            isLastRow = YES;
        }
        [pathCell configWithData:pointDic indexPath:indexPath andFold:self.showFold];
        [pathCell setIsLastRow:isLastRow];
        return pathCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.showFold) {
        if ([self.delegate respondsToSelector:@selector(onSelectPoint)]) {
            [self.delegate onSelectPoint];
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!tableView.editing) {
        return UITableViewCellEditingStyleNone;
    } else {
        return UITableViewCellEditingStyleDelete;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete: {
            if (self.pathPointArray.count < 2) {
                [DNPromptView showToast:@"路线模拟至少需要两个路径点"];
            } else {
                self.didEdited = YES;
                [self.pathPointArray removeObjectAtIndex:indexPath.row];
                [tableView beginUpdates];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                [tableView endUpdates];
            }
            break;
        }
        default:
            break;
    }
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    self.didEdited = YES;
    [self.pathPointArray exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    [tableView exchangeSubviewAtIndex:sourceIndexPath.row withSubviewAtIndex:destinationIndexPath.row];
}

#pragma mark - DNRoutePathCellDelegate

- (void)handlePathCellEvent:(DNPathCellEvent)event withIndexPath:(NSIndexPath *)indexPath
{
    if (DNPathCellSelectEvent == event) {
        [self gotoChoosePoint:indexPath];
    }
}

- (void)gotoChoosePoint:(NSIndexPath *)indexPath
{
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setValue:self.pathPointArray forKey:@"PathInfo"];
    [paramsDic setValue:indexPath forKey:@"IndexPath"];
    
    NSString *url = @"root/push/DNRoutePointController";
    [[DNRouteManager sharedInstance] routeURLStr:url withParamsDic:paramsDic];
}

#pragma mark - Privates

- (void)layoutPathView
{
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = DNColorF6F6F6;
    bgView.layer.cornerRadius = 4;
    bgView.layer.borderColor = DNColorD6D6D6.CGColor;
    bgView.layer.borderWidth = 1/[UIScreen mainScreen].scale;
    [self addSubview:bgView];
    
    [self.pathTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(27);
        make.left.equalTo(self);
        make.bottom.equalTo(self).offset(-1/[UIScreen mainScreen].scale);
        make.right.equalTo(self.editPathBtn.mas_left).offset(-2);
    }];
    [self.blankImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(32);
        make.left.equalTo(self).offset(23);
        make.size.mas_equalTo(CGSizeMake(6, 8));
    }];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(10);
        make.bottom.equalTo(self).offset(-10);
        make.right.equalTo(self).offset(-8);
        make.width.mas_equalTo(@(36));
    }];
    [self.editPathBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(@(52));
        make.top.bottom.right.equalTo(self);
    }];
}

#pragma mark - Getters

- (NSMutableArray *)pathPointArray
{
    if (!_pathPointArray) {
        NSArray *testArray = @[@{@"index": @(1),
                                 @"value":@{@"address": @"我的位置"}}];
        _pathPointArray = [NSMutableArray arrayWithArray:testArray];
    }
    return _pathPointArray;
}

- (UIButton *)editPathBtn
{
    if (!_editPathBtn) {
        UIImage *normalImg = [UIImage imageNamed:@"DNFeature.bundle/route_path_edit_normal"];
        UIImage *finishImg = [UIImage imageNamed:@"DNFeature.bundle/route_path_edit_selected"];
        _editPathBtn = [[UIButton alloc] init];
        [_editPathBtn setImage:normalImg forState:UIControlStateNormal];
        [_editPathBtn setImage:finishImg forState:UIControlStateSelected];
        [_editPathBtn setTitleColor:DNColor9B9B9B forState:UIControlStateNormal];
        [_editPathBtn.titleLabel setFont:DNFont10];
        [_editPathBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_editPathBtn setTitle:@"编辑" forState:UIControlStateSelected];
        [_editPathBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 16, 16, 6)];
        [_editPathBtn setTitleEdgeInsets:UIEdgeInsetsMake(20, -12, 0, 8)];
        [_editPathBtn addTarget:self
                        action:@selector(onEditRoutePath:)
              forControlEvents:UIControlEventTouchUpInside];
        [_editPathBtn setTitle:@"完成" forState:UIControlStateNormal | UIControlStateHighlighted];
        [_editPathBtn setTitle:@"编辑" forState:UIControlStateSelected | UIControlStateHighlighted];
        [_editPathBtn setImage:normalImg forState:UIControlStateNormal | UIControlStateHighlighted];
        [_editPathBtn setImage:finishImg forState:UIControlStateSelected | UIControlStateHighlighted];
        [self addSubview:_editPathBtn];
    }
    return _editPathBtn;
}

- (UITableView *)pathTableView
{
    if (!_pathTableView) {
        _pathTableView = [[UITableView alloc] init];
        _pathTableView.delegate = self;
        _pathTableView.dataSource = self;
        _pathTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:_pathTableView];
    }
    return _pathTableView;
}

- (UIImageView *)blankImgView
{
    if (!_blankImgView) {
        _blankImgView = [[UIImageView alloc] initWithFrame:CGRectMake(23, 0, 6, 8)];
        _blankImgView.hidden = YES;
        _blankImgView.contentMode = UIViewContentModeScaleAspectFit;
        _blankImgView.image = [UIImage imageNamed:@"DNFeature.bundle/route_path_blank"];
        [self addSubview:_blankImgView];
    }
    return _blankImgView;
}

@end
