//
//  DNMapExtendController.m
//  DNFeature
//
//  Created by eisen.chen on 2018/9/8.
//

#import "DNMapExtendController.h"
#import "DNMapExtendViewCell.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width

@interface DNMapExtendController ()<DNMapExtendViewCellDelegate>

@property (weak, nonatomic) IBOutlet UIView *extendView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *mapTypeBtns;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *extendViewTrailing;
@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint *mapTypeViewToping;

@property (nonatomic, strong) NSMutableArray *dataList;

@end

@implementation DNMapExtendController

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = DNColorD9D9D9;
    self.navigationController.navigationBarHidden = YES;
    
    NSDictionary *dataDic = [[NSUserDefaults standardUserDefaults] objectForKey:kMapExtendData];
    if (!dataDic) { //设置默认数据
        dataDic = @{@"maptype": @(2), @"trafic": @(NO), @"thermal": @(NO)};
        [[NSUserDefaults standardUserDefaults] setObject:dataDic forKey:kMapExtendData];
    }
    NSInteger maptype = [[dataDic valueForKey:@"maptype"] integerValue];
    for (UIButton *typeBtn in self.mapTypeBtns) {
        if (typeBtn.tag == maptype) {
            typeBtn.layer.borderWidth = 2;
        } else {
            typeBtn.layer.borderWidth = 0;
        }
    }
}

- (void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
    
    if (@available(iOS 11, *)) {
        UIEdgeInsets safeEdge = self.view.safeAreaInsets;
        self.mapTypeViewToping.constant = safeEdge.top + 20;
    }
}

#pragma mark - Actions

- (IBAction)onChangeMapType:(UIButton *)sender
{
    for (UIButton *typeBtn in self.mapTypeBtns) {
        if (typeBtn == sender) {
            typeBtn.layer.borderWidth = 2;
        } else {
            typeBtn.layer.borderWidth = 0;
        }
    }
    NSDictionary *userInfo = @{@"event": @"maptype",
                               @"value": @(sender.tag)};
    [self notifyMapView:userInfo];
    
    NSDictionary *tmpDic = [[NSUserDefaults standardUserDefaults] objectForKey:kMapExtendData];
    NSMutableDictionary *dataInfo = [NSMutableDictionary dictionaryWithDictionary:tmpDic];
    [dataInfo setValue:@(sender.tag) forKey:@"maptype"];
    [[NSUserDefaults standardUserDefaults] setObject:dataInfo forKey:kMapExtendData];
}

#pragma mark - DNMapExtendViewCellDelegate

- (void)handleSwitchChange:(BOOL)value forIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *tmpDic = [[NSUserDefaults standardUserDefaults] objectForKey:kMapExtendData];
    NSMutableDictionary *dataInfo = [NSMutableDictionary dictionaryWithDictionary:tmpDic];
    
    NSDictionary *dataDic = [self.dataList objectAtIndex:indexPath.row];
    NSString *title = [dataDic valueForKey:@"title"];
    NSDictionary *userInfo;
    if ([title isEqualToString:@"路况"]) {
        userInfo = @{@"event": @"trafic", @"value": @(value)};
        [dataInfo setObject:@(value) forKey:@"trafic"];
    } else if ([title isEqualToString:@"热力图"]) {
        userInfo = @{@"event": @"thermal", @"value": @(value)};
        [dataInfo setObject:@(value) forKey:@"thermal"];
    }
    
    if (userInfo) {
        [self notifyMapView:userInfo];
        [[NSUserDefaults standardUserDefaults] setObject:dataInfo forKey:kMapExtendData];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return YES;
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
        return 56;
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
        static NSString *cellIdentifier = @"DNMapExtendViewCellIden";
        DNMapExtendViewCell* extendCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (nil == extendCell) {
            UINib* nib = [UINib nibWithNibName:@"DNMapExtendViewCell" bundle:nil];
            extendCell = [nib instantiateWithOwner:nil options:nil].lastObject;
            [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
        }
        extendCell.delegate = self;
        [extendCell configWithData:dataDic andIndexPath:indexPath];
        return extendCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dataDic = [self.dataList objectAtIndex:indexPath.row];
    NSString *title = [dataDic valueForKey:@"title"];
    
    NSDictionary *userInfo;
    if ([title isEqualToString:@"输入经纬度"]) {
        userInfo = @{@"event": @"input"};
    } else if ([title isEqualToString:@"收藏/历史"]) {
        userInfo = @{@"event": @"collect"};
    } else if ([title isEqualToString:@"分享位置"]) {
        userInfo = @{@"event": @"share"};
    }
    
    if (userInfo) {
        [self notifyMapView:userInfo];
    }
}

#pragma mark - Privates

- (void)notifyMapView:(NSDictionary *)userInfo
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kSelectMapExtend
                                                        object:nil
                                                      userInfo:userInfo];
}

#pragma mark - Getters

- (NSMutableArray *)dataList
{
    if (!_dataList) {
        NSDictionary *dataDic = [[NSUserDefaults standardUserDefaults] objectForKey:kMapExtendData];
        BOOL trafic  = [[dataDic valueForKey:@"trafic"] boolValue];
        BOOL thermal = [[dataDic valueForKey:@"thermal"] boolValue];
        NSArray *array = @[@{@"itemImg": @"ic_traffic_light", @"title": @"路况", @"switch": @(trafic)},
                           @{@"itemImg": @"ic_thermal_graphics", @"title": @"热力图", @"switch": @(thermal)},
                           @{@"blank": @(YES)},
                           @{@"itemImg": @"ic_input", @"title": @"输入经纬度"},
                           @{@"itemImg": @"ic_collection", @"title": @"收藏/历史"},
                           @{@"itemImg": @"ic_share", @"title": @"分享位置"}];
        _dataList = [NSMutableArray arrayWithArray:array];
    }
    return _dataList;
}

@end
