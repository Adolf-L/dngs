/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNHomeViewController.m
 *
 * Description  : DNHomeViewController
 *
 * Author       : eisen
 *
 * History      : Creation, 2017/2/9, Create the file
 *****************************************************************************************
 **/

#import "DNHomeViewController.h"
#import "TalkingData.h"
#import "DNGPSManager.h"
#import "DNDrawerManager.h"
#import "BMKMapComponent.h"
#import "BMKSearchComponent.h"
#import "BMKGeometry.h"
#import "BMKLocationManager.h"
#import "DNShareView.h"
#import "DNFormatGps.h"
#import "DNTipView.h"
#import "DNCollectionUnit.h"
#import "DNEditLocationView.h"
#import "Reachability.h"

@interface DNHomeViewController () <BMKMapViewDelegate, BMKGeoCodeSearchDelegate, BMKLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *noticeImgView;
@property (weak, nonatomic) IBOutlet BMKMapView *mapView;          //百度地图视图
@property (weak, nonatomic) IBOutlet UIView     *noHardwareView;   //没有连接大牛Go硬件设备的提示
@property (weak, nonatomic) IBOutlet UILabel    *addressLabel;     //当前位置的地址
@property (weak, nonatomic) IBOutlet UILabel    *distanceLabel;    //当前位置距离真实位置的距离
@property (weak, nonatomic) IBOutlet UILabel    *latitudeLabel;    //当前位置的经纬度
@property (weak, nonatomic) IBOutlet UIButton   *mapExtendBtn;     //展开、折叠地图扩展功能的按钮
@property (weak, nonatomic) IBOutlet UIButton   *startHookBtn;     //开始模拟的按钮
@property (weak, nonatomic) IBOutlet UIButton   *addCollectionBtn; //收藏当前位置的按钮
@property (weak, nonatomic) IBOutlet UIButton   *showHookCoordBtn; //跳转模拟位置的按钮
@property (weak, nonatomic) IBOutlet UIButton   *showRealCoordBtn; //跳转真实位置的按钮
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchaBarToping;  //搜索框的顶部边距
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBarBottom;//位置详情的底部边距
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noHardwareToping;  //提示框的顶部边距

@property (nonatomic, strong) UIImageView        *curPointImgView; //当前位置的大头针
@property (nonatomic, strong) BMKGeoCodeSearch   *geoService;      //地址编码服务
@property (nonatomic, strong) BMKLocationManager *locationManager; //获取定位的对象
@property (nonatomic, strong) NSString           *realAddress;     //真实位置的地址
@property (nonatomic, assign) BOOL               isLocating;       //是否正在定位中
@property (nonatomic, assign) BOOL               isClickEvent;     //是否是点击地图事件，避免触发地图region变化后重新获取位置
@property (nonatomic, assign) BOOL               isFromHome;
@property (nonatomic, assign) CLLocationCoordinate2D realCoord;    //真实位置的经纬度
@property (nonatomic, assign) CLLocationCoordinate2D nowCoord;     //当前位置的经纬度

@end

@implementation DNHomeViewController

#pragma mark - Life cycle

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self layoutContentView];
}

- (void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
    
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeArea = self.view.safeAreaInsets;
        self.searchaBarToping.constant = safeArea.top;
        self.bottomBarBottom.constant = safeArea.bottom;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.mapView.showsUserLocation = YES;
    self.noticeImgView.hidden = ![DNProfileManager sharedInstance].hasNewNotice;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.realCoord.latitude == 0 && self.realCoord.longitude == 0) {
            [self.locationManager startUpdatingLocation];
        }
    });
    
    [[DNDrawerManager sharedInstance] startDrawer];
    [[DNGPSManager sharedInstance] checkConnecting];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.isFromHome = NO;
    self.mapView.showsUserLocation = NO;
    [[DNDrawerManager sharedInstance] stopDrawer];
}

#pragma mark - Actions

- (IBAction)showHardwareInfo:(UITapGestureRecognizer *)sender
{
    [[DNRouteManager sharedInstance] gotoWebsite:kDNGPSWebsite];
}

- (IBAction)showAppExtend:(id)sender
{
    //测试崩溃
    //    NSArray *testArray = @[@"Hello world!"];
    //    NSLog(@"%@", testArray[1]);
    
    [[DNDrawerManager sharedInstance] openDrawerSide:MMDrawerSideLeft];
}

- (IBAction)showMapExtend:(UIButton *)sender
{
    [[DNDrawerManager sharedInstance] openDrawerSide:MMDrawerSideRight];
}

- (IBAction)gotoRouteVC:(UIButton *)sender
{
    if (self.realCoord.latitude == 0 && self.realCoord.longitude == 0) {
        [[DNPromptView sharedInstance] showText:kStringForLocateFailed andRemove:1.2];
        return;
    }
    NSDictionary *paramsDic = @{@"latitude": @(self.realCoord.latitude),
                                @"longitude": @(self.realCoord.longitude),
                                @"address": self.realAddress};
    NSString *url = @"root/push/DNRouteSettingController";
    [[DNRouteManager sharedInstance] routeURLStr:url withParamsDic:paramsDic];
    [TalkingData trackEvent:kEventRoute label:kLabelRouteStepIn];
}

- (IBAction)gotoSearchVC:(id)sender
{
    NSString *url = @"root/push/DNMapSearchController";
    [[DNRouteManager sharedInstance] routeURLStr:url];
}

- (IBAction)startOrStopHook:(UIButton *)sender
{
    if (self.nowCoord.latitude == 0 && self.nowCoord.longitude == 0) {
        [[DNPromptView sharedInstance] showText:kStringForLocateFailed andRemove:1.2];
        return ;
    }
    
    if (![[DNGPSManager sharedInstance] isConnecting]) {
        [DNAlertView showAlert:@"未连接硬件设备"
                       message:nil
                    firstTitle:@"取消"
                   firstAction:nil
                   secondTitle:@"购买硬件"
                  secondAction:^{
                      [[DNRouteManager sharedInstance] gotoWebsite:kDNGPSMallUrl];
                  }];
        return ;
    }
    
    self.isFromHome = YES;
    if (!sender.selected) {
        // 将位置发送给硬件设备
        [[DNGPSManager sharedInstance] workWithCoord:self.nowCoord];
        [TalkingData trackEvent:kEventGlobal label:kLabelGlobalStart];
    } else {
        [[DNGPSManager sharedInstance] workForRealCoord:self.realCoord];
        [TalkingData trackEvent:kEventGlobal label:kLabelGlobalStop];
    }
}

- (IBAction)showHookedLocation:(UIButton *)sender
{
    NSDictionary *coordDic = [[NSUserDefaults standardUserDefaults] valueForKey:kHookedCoord];
    if (sender.selected && coordDic) {
        [DNPromptView showToast:@"已到达上一次的模拟位置"];
        return ;
    }
    
    if (coordDic) {
        CGFloat latitude  = [[coordDic valueForKey:@"latitude"] floatValue];
        CGFloat longitude = [[coordDic valueForKey:@"longitude"] floatValue];
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(latitude, longitude);
        CLLocationCoordinate2D baiduCoor = BMKCoordTrans(coord, BMK_COORDTYPE_GPS, BMK_COORDTYPE_BD09LL);
        self.showHookCoordBtn.selected = YES;
        self.isClickEvent = YES;
        self.startHookBtn.selected = YES;
        self.startHookBtn.backgroundColor = DNColorE53935;
        self.showRealCoordBtn.selected = NO;
        [self.mapView setCenterCoordinate:baiduCoor animated:YES];
        [self showImageTagAtCenter];
    } else {
        [DNPromptView showToast:@"当前没有模拟的位置信息"];
    }
}

- (IBAction)showRealLocation:(UIButton *)sender
{
    if (sender.selected && self.realCoord.latitude != 0) {
        [DNPromptView showToast:@"已到达真实位置"];
        return;
    }
    
    if (self.realCoord.latitude != 0 || self.realCoord.longitude != 0) {
        self.showRealCoordBtn.selected = YES;
        self.isClickEvent = YES;
        self.startHookBtn.selected = NO;
        self.startHookBtn.backgroundColor = DNColor27C411;
        self.showRealCoordBtn.selected = YES;
        CLLocationCoordinate2D huoxing = [[DNFormatGps sharedIntances] baiduGpsToGCJ:self.realCoord];
        self.nowCoord = [[DNFormatGps sharedIntances] gcjToGPS:huoxing];
        [self updateHookBtnState:self.nowCoord];
        self.addressLabel.text = self.realAddress;
        self.distanceLabel.text = @"距你0米";
        [self.mapView setCenterCoordinate:self.realCoord animated:YES];
        [self showImageTagAtCenter];
    } else {
        if ([self isNetworkOK]) {
            [self.locationManager startUpdatingLocation];
        } else {
            self.addressLabel.text = kStringForNoNetwork;
        }
    }
}

- (IBAction)addCollection:(id)sender
{
    UIButton* pressedBtn = (UIButton*)sender;
    if (pressedBtn.selected == YES) {
        [DNPromptView showToast:@"已存在，不能重复收藏"];
        return;
    }
    pressedBtn.selected = YES;
    
    if ([DNCollectionUnit collectCoord:self.nowCoord withAddress:self.addressLabel.text]) {
        [DNPromptView showToast:@"收藏成功"];
    } else {
        [DNPromptView showToast:@"已存在，不能重复收藏"];
    }
}

- (IBAction)shareLocation:(UIButton *)sender
{
    [self shareCurrentLocation];
}

#pragma mark - BMKMapViewDelegate

- (void)mapView:(BMKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    if (self.isClickEvent) {
        return ;
    }
    self.addressLabel.text  = @"松开地图以加载";
    self.distanceLabel.text = @"距你0米";
    self.latitudeLabel.text = @"0.000000";
}

- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (self.isClickEvent) {
        self.isClickEvent = NO;
        return;
    }
    
    self.addCollectionBtn.selected = NO;
    CGPoint center = CGPointMake(self.mapView.center.x, self.mapView.frame.size.height/2);
    CLLocationCoordinate2D touchLocation = [self.mapView convertPoint:center
                                                 toCoordinateFromView:self.mapView];
    [self addAnnotationAtLocation:touchLocation];
}

- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate
{
    self.isClickEvent = YES;
    [self addAnnotationAtLocation:coordinate];
}

#pragma mark - BMKGeoCodeSearchDelegate

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher
                           result:(BMKReverseGeoCodeSearchResult *)result
                        errorCode:(BMKSearchErrorCode)error
{
    if (result.location.latitude/1 == 0 || result.location.longitude/1 == 0) {
        return;
    }
    
    //如果是定位状态，只获取当前所在的城市，不做大头针操作
    if (self.isLocating) {
        self.isLocating = NO;
        self.showRealCoordBtn.selected = YES;
        self.addressLabel.text = result.address;
        self.distanceLabel.text = @"距你0米";
        if ((int)result.location.latitude == 0 && (int)result.location.longitude == 0) {
            [self.locationManager startUpdatingLocation];
        } else {
            self.realCoord = result.location;
            self.realAddress = result.address;
        }
    } else {
        self.showRealCoordBtn.selected = NO;
        self.startHookBtn.selected = NO;
        self.startHookBtn.backgroundColor = DNColor27C411;
        BMKMapPoint po1 = BMKMapPointForCoordinate(result.location);
        BMKMapPoint po2 = BMKMapPointForCoordinate(self.realCoord);
        CLLocationDistance distanceVal = BMKMetersBetweenMapPoints(po1,po2);
        NSString* distabceStr = [NSString stringWithFormat:@"距你%.fm", distanceVal];
        if (distanceVal > 1000) {
            distabceStr = [NSString stringWithFormat:@"距你%.1fkm", distanceVal/1000];
        }
        if (distanceVal > 100000) {
            distabceStr = [NSString stringWithFormat:@"距你%.fkm", distanceVal/1000];
        }
        
        self.addressLabel.text = result.address;
        self.distanceLabel.text = distabceStr;
    }
    
    CLLocationCoordinate2D huoxing = [[DNFormatGps sharedIntances] baiduGpsToGCJ:result.location];
    self.nowCoord = [[DNFormatGps sharedIntances] gcjToGPS:huoxing];
    if (self.isClickEvent) {
        [self.mapView setCenterCoordinate:result.location animated:YES];
    }
    [self updateHookBtnState:self.nowCoord];
    [self showImageTagAtCenter];
}

#pragma mark - BMKLocationManagerDelegate

- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didFailWithError:(NSError * _Nullable)error
{
    if (error && error.code == 2) {
        [DNAlertView showAlert:@"定位失败"
                       message:@"请设置大牛GPS允许定位权限"
                    firstTitle:@"知道了"
                   firstAction:^{
                       self.addressLabel.text = @"当前没有定位权限";
                   }
                   secondTitle:@"设置"
                  secondAction:^{
                      NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                      if ([[UIApplication sharedApplication] canOpenURL:url]) {
                          [[UIApplication sharedApplication] openURL:url];
                      }
                  }];
    }
}

// 定位SDK中，位置变更的回调
- (void)BMKLocationManager:(BMKLocationManager *)manager didUpdateLocation:(BMKLocation *)location orError:(NSError *)error
{    
    if (location && !error) {
        self.isLocating = YES;
        self.isClickEvent = YES;
        BMKUserLocation *userLocation = [[BMKUserLocation alloc] init];
        userLocation.location = location.location;
        [self.mapView updateLocationData:userLocation];
        [self addAnnotationAtLocation:location.location.coordinate];
    } else {
        if ([self isNetworkOK]) {
            self.addressLabel.text = @"网络信号差，获取位置信息失败";
        } else {
            self.addressLabel.text = kStringForNoNetwork;
        }
    }
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - Privates

- (void)layoutContentView
{
    self.isClickEvent      = YES;
    self.mapView.delegate  = self;
    self.mapView.zoomLevel = 17;
    self.nowCoord = CLLocationCoordinate2DMake(0, 0);
    self.navigationController.navigationBarHidden = YES;
    
    BMKLocationViewDisplayParam *displayParam = [[BMKLocationViewDisplayParam alloc] init];
    displayParam.isAccuracyCircleShow = NO; //精度圈是否显示
    [self.mapView updateLocationViewWithParam:displayParam];
    
    UIImage *backgroundImg = [UIImage imageFromColor:DNColorD9D9D9];
    [self.mapExtendBtn setBackgroundImage:backgroundImg forState:UIControlStateHighlighted];
    [self.showHookCoordBtn setBackgroundImage:backgroundImg forState:UIControlStateHighlighted];
    [self.showRealCoordBtn setBackgroundImage:backgroundImg forState:UIControlStateHighlighted];
    
    [[DNDrawerManager sharedInstance].rootVC setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
        if (MMDrawerSideRight == drawerSide) {
            self.mapExtendBtn.transform = CGAffineTransformMakeRotation(-percentVisible * M_PI);
            UIViewController *rightVC = drawerController.rightDrawerViewController;
            [rightVC.view setAlpha:percentVisible];
        }
        if (MMDrawerSideLeft == drawerSide) {
            UIViewController *leftVC = drawerController.leftDrawerViewController;
            [leftVC.view setAlpha:percentVisible];
        }
    }];
    
    NSDictionary *coordDic = [[NSUserDefaults standardUserDefaults] valueForKey:kHookedCoord];
    self.showHookCoordBtn.selected = (coordDic == nil);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleCollectionPoint:)
                                                 name:SelectCollectionPoint
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSearchPoint:)
                                                 name:SelectSearchPoint
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSelectExtendCenter:)
                                                 name:kSelectExtendCenter
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMapExtendNotification:)
                                                 name:kSelectMapExtend
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleiOSProfile)
                                                 name:iOSProfileDone
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSendGPSResult:)
                                                 name:kSendGPSDoneNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideNoHardwareView)
                                                 name:kGPSDidConnectNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showNoHardwareView)
                                                 name:kGPSDidDisconnectNotification
                                               object:nil];
}

- (void)handleCollectionPoint:(NSNotification *)notify
{
    CGFloat latitude  = [[notify.userInfo objectForKey:@"latitude"] floatValue];
    CGFloat longitude = [[notify.userInfo objectForKey:@"longitude"] floatValue];
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(latitude, longitude);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isClickEvent = YES;
        CLLocationCoordinate2D baiduCoor = BMKCoordTrans(coord, BMK_COORDTYPE_GPS, BMK_COORDTYPE_BD09LL);
        [self addAnnotationAtLocation:baiduCoor];
    });
}

- (void)handleSearchPoint:(NSNotification *)notify
{
    self.isClickEvent = YES;
    
    CGFloat latitude  = [[notify.userInfo valueForKey:@"latitude"] floatValue];
    CGFloat longitude = [[notify.userInfo valueForKey:@"longitude"] floatValue];
    if (latitude != 0 && longitude != 0) {
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(latitude, longitude);
        [self addAnnotationAtLocation:coord];
        
        if (self.mapView.zoomLevel < 17) {
            self.mapView.zoomLevel = 17;
        }
    }
}

- (void)handleMapExtendNotification:(NSNotification *)notify
{
    NSString *event = [notify.userInfo valueForKey:@"event"];
    id value = [notify.userInfo valueForKey:@"value"];
    if ([event isEqualToString:@"maptype"]) {
        if (1 == [value integerValue]) {//卫星图
            [self.mapView setMapType:BMKMapTypeSatellite];
            [self.mapView setBuildingsEnabled:NO];
            self.mapView.overlooking = 0;
        } else if (2 == [value integerValue]) {//2D平面图
            [self.mapView setMapType:BMKMapTypeStandard];
            [self.mapView setBuildingsEnabled:NO];
            self.mapView.overlooking = 0;
        } else {//3D俯视图
            [self.mapView setBuildingsEnabled:YES];
            self.mapView.overlooking = -45;
        }
    } else if ([event isEqualToString:@"trafic"]) {
        [self.mapView setTrafficEnabled:[value boolValue]];
    } else if ([event isEqualToString:@"thermal"]) {
        [self.mapView setBaiduHeatMapEnabled:[value boolValue]];
    } else if ([event isEqualToString:@"input"]) {
        [[DNDrawerManager sharedInstance] closeDrawerAnimated:YES completion:nil];
        [[DNDrawerManager sharedInstance] stopDrawer];
        [self inputCoordForMap];
    } else if ([event isEqualToString:@"collect"]) {
        [[DNDrawerManager sharedInstance] closeDrawerAnimated:YES completion:nil];
        NSString *url = @"root/push/DNCollectionController";
        [[DNRouteManager sharedInstance] routeURLStr:url];
    } else if ([event isEqualToString:@"share"]) {
        [[DNDrawerManager sharedInstance] closeDrawerAnimated:YES completion:nil];
        [[DNDrawerManager sharedInstance] stopDrawer];
        [self shareCurrentLocation];
    }
}

- (void)handleSelectExtendCenter:(NSNotification *)notify
{
    [[DNDrawerManager sharedInstance] closeDrawerAnimated:YES completion:nil];
    
    NSString *title = [notify.userInfo valueForKey:@"title"];
    if ([title isEqualToString:@"大牛家族"]) {
        NSString *url = @"root/push/DNFamilyController";
        [[DNRouteManager sharedInstance] routeURLStr:url];
    } else if ([title isEqualToString:@"分享软件"]) {
        [[DNDrawerManager sharedInstance] stopDrawer];
        DNShareView *shareView = [[DNShareView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        shareView.publicContent = @"大牛GPS，发现手机更多有趣功能!\n www.daniu.net";
        shareView.sessionContent = @"大牛GPS，发现手机更多有趣功能!\n www.daniu.net";
        shareView.shareImage = [UIImage imageNamed:@"DNHome.bundle/Daniu_Share_logo.png"];
        shareView.title = @"分享大牛GPS给好友";
        shareView.finishBlock = ^{
            [[DNDrawerManager sharedInstance] startDrawer];
        };
        [self.view addSubview:shareView];
        [shareView showStartAnimation];
    } else if ([title isEqualToString:@"设置"]) {
        NSString *url = @"root/push/DNSettingController";
        [[DNRouteManager sharedInstance] routeURLStr:url];
    } else if ([title isEqualToString:@"通知"]) {
        NSString *url = @"root/push/DNNoticeViewController";
        [[DNRouteManager sharedInstance] routeURLStr:url];
    }
}

- (void)handleiOSProfile
{
    self.noticeImgView.hidden = ![DNProfileManager sharedInstance].hasNewNotice;
}

- (void)handleSendGPSResult:(NSNotification *)notify
{
    BOOL result = [[notify.userInfo valueForKey:@"HookCoord"] boolValue];
    if (self.isFromHome && result) {
        self.isFromHome = NO;
        self.startHookBtn.selected = !self.startHookBtn.selected;
        if (self.startHookBtn.selected) {
            self.startHookBtn.backgroundColor = DNColorE53935;
        } else {
            self.startHookBtn.backgroundColor = DNColor27C411;
        }
        
        if (self.startHookBtn.selected) {
            // 将模拟位置添加到历史记录
            NSDictionary *coordDic = @{@"latitude": @(self.nowCoord.latitude),
                                       @"longitude": @(self.nowCoord.longitude)};
            [[NSUserDefaults standardUserDefaults] setValue:coordDic forKey:kHookedCoord];
            [DNCollectionUnit historyCoord:self.nowCoord withAddress:self.addressLabel.text];
            
            DNTipView* tipView = [[[NSBundle mainBundle] loadNibNamed:@"DNTipView" owner:self options:nil] lastObject];
            tipView.addressLabel.attributedText = [[NSAttributedString alloc] initWithString:self.addressLabel.text];
            tipView.detailLabel.text = [NSString stringWithFormat:@"经度: %.6f  纬度: %.6f",
                                        self.nowCoord.longitude,
                                        self.nowCoord.latitude];;
            [self.view addSubview:tipView];
        } else {
            self.showHookCoordBtn.selected = YES;
            [DNPromptView showToast:@"已停止位置模拟"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kHookedCoord];
        }
        [TalkingData trackEvent:kEventGlobal label:kLabelGlobalSuccess];
    }
}

- (void)hideNoHardwareView
{
    self.noHardwareView.hidden = YES;
}

- (void)showNoHardwareView
{
    self.noHardwareView.hidden = NO;
}

- (void)inputCoordForMap
{
    __weak __typeof(self) weakSelf = self;
    DNEditLocationView *editView = [[NSBundle mainBundle] loadNibNamed:@"DNEditLocationView" owner:self options:nil].firstObject;
    editView.frame = self.view.frame;
    editView.editBlock = ^(CLLocationCoordinate2D coord){
        if (coord.latitude != 0 && coord.longitude != 0) {
            weakSelf.isClickEvent = YES;
            [weakSelf addAnnotationAtLocation:coord];
        }
        [[DNDrawerManager sharedInstance] startDrawer];
    };
    [self.view addSubview:editView];
}

- (void)shareCurrentLocation
{
    NSString *contentStr = [NSString stringWithFormat:@"大牛GPS位置分享，%@，经度:%.6f，纬度:%.6f",
                            self.addressLabel.text,
                            self.nowCoord.longitude,
                            self.nowCoord.latitude];
    DNShareView* shareView = [[DNShareView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    shareView.publicContent = contentStr;
    shareView.sessionContent = contentStr;
    shareView.title = @"分享当前位置给好友";
    shareView.finishBlock = ^{
        [[DNDrawerManager sharedInstance] startDrawer];
    };
    [self.view addSubview:shareView];
    [shareView showStartAnimation];
}

- (void)addAnnotationAtLocation:(CLLocationCoordinate2D)location
{
    if (![self isNetworkOK]) {
        self.addressLabel.text = kStringForNoNetwork;
        return ;
    }
    BMKReverseGeoCodeSearchOption* reverseOption = [[BMKReverseGeoCodeSearchOption alloc] init];
    reverseOption.location = location;
    [self.geoService reverseGeoCode:reverseOption];
}

- (void)updateHookBtnState:(CLLocationCoordinate2D)nowCoord
{
    BOOL result = NO;
    NSDictionary *coordDic = [[NSUserDefaults standardUserDefaults] valueForKey:kHookedCoord];
    if (coordDic) {
        CGFloat latitude  = [[coordDic valueForKey:@"latitude"] floatValue];
        CGFloat longitude = [[coordDic valueForKey:@"longitude"] floatValue];
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(latitude, longitude);
        
        if (fabs((coord.latitude-nowCoord.latitude)*1000000) < 8 &&
            fabs((coord.longitude-nowCoord.longitude)*1000000) < 8) {
            result = YES;
        }
        self.showHookCoordBtn.selected = result;
    } else {
        self.showHookCoordBtn.selected = YES;
    }
    self.startHookBtn.selected = result;
    if (result) {
        self.startHookBtn.backgroundColor = DNColorE53935;
    } else {
        self.startHookBtn.backgroundColor = DNColor27C411;
    }
}

- (void)showImageTagAtCenter
{
    //1.创建动画对象
    CGPoint center = CGPointMake(self.mapView.center.x, self.mapView.frame.size.height/2 - 20);
    self.curPointImgView.center = center;
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animation];
    anim.keyPath = @"position";
    anim.values = @[[NSValue valueWithCGPoint:CGPointMake(center.x, center.y)],
                    [NSValue valueWithCGPoint:CGPointMake(center.x, center.y-10)],
                    [NSValue valueWithCGPoint:CGPointMake(center.x, center.y)]];
    anim.repeatCount =  1;
    anim.duration = 0.5;
    [self.curPointImgView.layer addAnimation:anim forKey:nil];
}

- (BOOL)isNetworkOK
{
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.apple.com"];
    return (NotReachable != [reach currentReachabilityStatus]);
}

#pragma mark - Setters

- (void)setNowCoord:(CLLocationCoordinate2D)nowCoord
{
    _nowCoord = nowCoord;
    
    if (nowCoord.latitude == 0 && nowCoord.longitude == 0) {
        return ;
    }
    if ([UIScreen mainScreen].bounds.size.width < 375) {
        self.latitudeLabel.text = [NSString stringWithFormat:@"经纬度(%.3f,%.3f)",
                                   nowCoord.longitude,
                                   nowCoord.latitude];
    } else {
        self.latitudeLabel.text = [NSString stringWithFormat:@"经度:%.6f  纬度:%.6f",
                                   nowCoord.longitude,
                                   nowCoord.latitude];
    }
}

#pragma mark - Getters

- (BMKGeoCodeSearch *)geoService
{
    if (!_geoService) {
        _geoService = [[BMKGeoCodeSearch alloc] init];
        _geoService.delegate = self;
    }
    return _geoService;
}

- (BMKLocationManager *)locationManager
{
    if (!_locationManager){
        _locationManager = [[BMKLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.coordinateType = BMKLocationCoordinateTypeBMK09LL;
    }
    return _locationManager;
}

- (UIImageView *)curPointImgView
{
    if (!_curPointImgView) {
        _curPointImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, 40)];
        _curPointImgView.image = [UIImage imageNamed:@"DNFeature.bundle/map_now_coord"];
        [self.mapView addSubview:_curPointImgView];
    }
    return _curPointImgView;
}

@end
