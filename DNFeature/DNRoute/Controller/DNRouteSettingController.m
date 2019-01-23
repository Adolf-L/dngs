/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNRouteSettingController.m
 *
 * Description  : DNRouteSettingController
 *
 * Author       : eisen
 *
 * History      : Creation, 2018/6/27, Create the file
 *****************************************************************************************
 **/

#import "DNRouteSettingController.h"
#import "TalkingData.h"
#import "DNRouteTypeView.h"
#import "DNRoutePathView.h"
#import "DNRouteSettingView.h"
#import "BMKMapView.h"
#import "BMKGeometry.h"
#import "BMKRouteSearch.h"
#import "BMKPolylineView.h"
#import "BMKPointAnnotation.h"
#import "BMKPinAnnotationView.h"
#import "DNRouteModel.h"
#import "DNRoutePointView.h"
#import "DNPointRuleView.h"
#import "DNShareView.h"
#import "UIView+Additions.h"
#import <Photos/Photos.h>

@interface DNRouteSettingController ()<DNRoutePathViewDelegate, DNRouteTypeViewDelegate,
                                       DNRouteSettingViewDelegate, DNPointRuleViewDelegate,
                                       BMKMapViewDelegate, BMKRouteSearchDelegate, BMKGeoCodeSearchDelegate>

@property (weak, nonatomic) IBOutlet BMKMapView      *mapView;
@property (weak, nonatomic) IBOutlet DNRoutePathView *routePathView;
@property (weak, nonatomic) IBOutlet UILabel         *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel         *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel         *durationLabel;
@property (weak, nonatomic) IBOutlet UIView          *shadeView;
@property (weak, nonatomic) IBOutlet UIButton        *addPointBtn;
@property (weak, nonatomic) IBOutlet UIButton        *realCoordBtn;
@property (weak, nonatomic) IBOutlet UIButton        *extendBtn;
@property (weak, nonatomic) IBOutlet UIButton        *shareBtn;
@property (weak, nonatomic) IBOutlet UIButton        *settingBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navViewToping;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *routePathToping;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *routePathLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startBtnWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startBtnHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *routePathHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoViewBottm;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceLabelToping;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionLabelToping;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *extendBtnLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *showRealBtnLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareBtnTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingBtnTrailing;

@property (nonatomic, strong) DNRouteSettingView  *settingView;      //导航设置视图
@property (nonatomic, strong) DNRoutePointView    *curPointView;     //当前点的大头针
@property (nonatomic, strong) DNPointRuleView     *pointRuleView;    //新点生成规则的视图
@property (nonatomic, strong) DNRouteModel        *routeModel;       //
@property (nonatomic, strong) NSMutableDictionary *routeLines;       //搜索所得的路径
@property (nonatomic, strong) NSMutableArray      *keyPoints;        //路线的各个关键点
@property (nonatomic, strong) NSMutableArray      *routeSearchArray; //存放BMKRouteSearch对象
@property (nonatomic, strong) BMKGeoCodeSearch    *geoService;       //地址编码
@property (nonatomic, assign) BMKCoordinateRegion coordsRegion;      //路线中所有点的region
@property (nonatomic, strong) NSString            *realAddress;      //真实位置的地址
@property (nonatomic, assign) CLLocationCoordinate2D realCoord;      //真实位置的经纬度
@property (nonatomic, assign) CLLocationCoordinate2D nowCoord;       //当前位置的经纬度

@property (nonatomic, assign) BOOL        didEdited;     //从路线收藏中选择路线后，是否有重新编辑
@property (nonatomic, assign) BOOL        isClickEvent;  //region改变时是否需要响应
@property (nonatomic, assign) BOOL        everShowSetting;
@property (nonatomic, assign) int         linesCount;    //路线的折线数量
@property (nonatomic, assign) int         traificCount;  //路线中的红灯数量
@property (nonatomic, assign) int         routeDistance; //路线的总距离
@property (nonatomic, assign) NSInteger   currentIndex;  //当前途径点的编号
@property (nonatomic, assign) NSInteger   randomCount;
@property (nonatomic, assign) DNPointRule pointRule;     //新点生成规则
@property (nonatomic, strong) NSTimer     *randomTimer;

@end

@implementation DNRouteSettingController

#pragma mark - Life cycle

- (void)dealloc
{
    [self.randomTimer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configWithParams:(NSDictionary *)params
{
    CGFloat latitude  = [[params valueForKey:@"latitude"] floatValue];
    CGFloat longitude = [[params valueForKey:@"longitude"] floatValue];
    if (latitude != 0 && longitude != 0) {
        NSDictionary *pointDic = @{@"latitude": [params valueForKey:@"latitude"],
                                   @"longitude": [params valueForKey:@"longitude"],
                                   @"address": [params valueForKey:@"address"]};
        [self.keyPoints addObject:pointDic];
        self.realCoord = CLLocationCoordinate2DMake(latitude, longitude);
        self.nowCoord  = self.realCoord;
        self.realAddress = [params valueForKey:@"address"];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self layoutSettingView];
}

- (void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
    
    if (@available(iOS 11, *)) {
        UIEdgeInsets safeEdge = self.view.safeAreaInsets;
        self.navViewToping.constant = safeEdge.top;
        self.navViewHeight.constant = 44;
        self.routePathToping.constant = safeEdge.top + 44;
        self.infoViewBottm.constant = safeEdge.bottom;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.mapView.showsUserLocation = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self showCenterWithAnimate:YES];
    [self.routePathView configWithPoints:self.keyPoints];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    if (![[NSUserDefaults standardUserDefaults] valueForKey:kNewPointRule]) {
        [self.pointRuleView showContentWithCenter:self.extendBtn.center andSize:self.extendBtn.frame.size];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.mapView.showsUserLocation = NO;  //不再显示定位图层
    if (self.settingView.hidden == NO) {
        [self.settingView stopSetting];
    }
}

#pragma mark - Actions

- (IBAction)onBack:(UIButton *)sender
{
    if (self.routePathView.isEditing || self.routePathView.showFold) {
        [self.randomTimer setFireDate:[NSDate distantPast]];
        [self.routePathView stopEditPoints];
        if (self.settingView.hidden == NO) {
            [self.settingView stopSetting];
        }
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)onSearchPoint:(UIButton *)sender
{
    NSString *url = @"root/push/DNMapSearchController";
    [[DNRouteManager sharedInstance] routeURLStr:url];
}

- (IBAction)showRealLocation:(UIButton *)sender
{
    if (sender.selected) {
        [DNPromptView showToast:@"已到达真实位置"];
        return;
    }
    sender.selected = YES;
    
    if (self.realCoord.latitude != 0 || self.realCoord.longitude != 0) {
        self.isClickEvent = YES;
        [self.mapView setCenterCoordinate:self.realCoord animated:YES];
        [self showCenterWithAnimate:YES];
        [self showPathForCoord:self.realCoord withAddress:self.realAddress];
    }
}

- (IBAction)showSettingView:(UIButton *)sender
{
    [self onSettingDetail];
}

- (IBAction)showExtendView:(UIButton *)sender
{
    [self.pointRuleView showContentWithCenter:sender.center andSize:sender.frame.size];
}

- (IBAction)onSharePreview:(UIButton *)sender
{
    [[DNPromptView sharedInstance] showLoadingText:@"保存预览图片中"];
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    if (authStatus != PHAuthorizationStatusAuthorized) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == PHAuthorizationStatusAuthorized) {
                    UIImageWriteToSavedPhotosAlbum([self.mapView takeSnapshot],
                                                   self,
                                                   @selector(image:didFinishSavingWithError:contextInfo:),
                                                   nil);
                    
                } else {
                    [DNAlertView showAlert:@"大牛GPS无法访问你的相册"
                                   message:@"请在iPhone的设置-隐私-照片中允许访问"
                                firstTitle:@"取消"
                               firstAction:nil
                               secondTitle:@"设置"
                              secondAction:^{
                                  NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                  if ([[UIApplication sharedApplication] canOpenURL:url]) {
                                      [[UIApplication sharedApplication] openURL:url];
                                  }
                              }];
                }
            });
        }];
    } else {
        UIImageWriteToSavedPhotosAlbum([self.mapView takeSnapshot],
                                       self,
                                       @selector(image:didFinishSavingWithError:contextInfo:),
                                       nil);
    }
}

// 成功保存图片到相册中, 必须调用此方法, 否则会报参数越界错误
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (!error) {
        [DNAlertView showSheetWithTitle:@"已保存预览图片到手机相册"
                                 Values:@[@"去微信分享", @"去QQ分享"]
                              andAction:^(NSString * _Nonnull title) {
                                  NSURL *appUrl;
                                  if ([title containsString:@"微信"]) {
                                      appUrl = [NSURL URLWithString:@"wechat://session"];
                                  }
                                  if ([title containsString:@"QQ"]) {
                                      appUrl = [NSURL URLWithString:@"mqq://im/chat?chat_type=wpa"];
                                  }
                                  if (appUrl && [[UIApplication sharedApplication] canOpenURL:appUrl]) {
                                      [[UIApplication sharedApplication] openURL:appUrl];
                                  }
                              } cancel:nil];
    }
}

- (IBAction)showCollection:(UIButton *)sender
{
    NSString *url = @"root/push/DNRouteCollectionController";
    [[DNRouteManager sharedInstance] routeURLStr:url];
}

- (IBAction)onAddPoint:(UIButton *)sender
{
    if (sender.selected) {
        NSInteger count = [[DNFmdbUnit sharedInstance] dnSearchModelArr:[DNRouteModel class]].count;
        NSString *bundleID = [NSString stringWithFormat:@"route%ld", (long)count+1];
        if (self.didEdited && ![self.routeModel.bundleID isEqualToString:bundleID]) {
            self.routeModel.bundleID = bundleID;
        }
        [self startRoute];
    } else {
        static NSTimeInterval sAddPointTime = 0;
        NSTimeInterval curTime = [[NSDate date] timeIntervalSince1970];
        if (fabs(curTime - sAddPointTime) < 0.5) {
            return ; //防连点
        }
        sAddPointTime = [[NSDate date] timeIntervalSince1970];
        
        self.didEdited = YES;
        if (self.pointRule == DNPointRuleCenter && self.keyPoints.count > 1) {
            [self showAllPointsAndRoute:NO];
        } else {
            BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
            item.title = [NSString stringWithFormat:@"%ld", (long)self.keyPoints.count];;
            item.coordinate = self.nowCoord;
            [self.mapView addAnnotation:item];
            
            CGPoint center = CGPointMake(self.mapView.center.x, self.mapView.bounds.size.height/2);
            if (self.pointRule == DNPointRuleTop) {
                center.y -= 50;
            } else if (self.pointRule == DNPointRuleLeft) {
                center.x -= 50;
            } else if (self.pointRule == DNPointRuleBootom) {
                center.y += 50;
            } else {
                center.x += 50;
            }
            CLLocationCoordinate2D newLocation = [self.mapView convertPoint:center
                                                       toCoordinateFromView:self.mapView];
            self.isClickEvent = YES;
            [self addAnnotationAtLocation:newLocation];
        }
        self.currentIndex++;
        [self.addPointBtn setTitle:@"设为途径点" forState:UIControlStateNormal];
    }
}

- (IBAction)onTapShadeView:(UITapGestureRecognizer *)sender
{
    [self.routePathView stopEditPoints];
}

#pragma mark - DNRouteTypeViewDelegate

- (void)didChangeType:(DNRouteType)type
{
    self.routeModel.routeType = type;
    if (self.settingView.hidden == NO) {
        [self.settingView configWithModel:self.routeModel];
    } else {
        [self showAllPointsAndRoute:YES];
    }
}

- (void)onSettingDetail
{
    static NSTimeInterval lastSettingTime = 0;
    NSTimeInterval curTime = [[NSDate date] timeIntervalSince1970];
    if (fabs(curTime - lastSettingTime) < 0.3 ) {
        return ; //防止频繁响应
    }
    lastSettingTime = curTime;
    
    self.durationLabel.text = @"";
    if (YES == self.settingView.hidden) {
        self.distanceLabel.text = @"导航设置中...";
        [self.settingView configWithModel:self.routeModel];
    } else {
        self.distanceLabel.text = @"路线规划中...";
        [self.settingView stopSetting];
    }
}

#pragma mark - DNRoutePathViewDelegate

- (void)onSelectPoint
{
    NSArray *array = [NSArray arrayWithArray:self.mapView.overlays];
    [self.mapView removeOverlays:array];
    if (self.settingView.hidden == NO) {
        [self.settingView stopSetting];
    }
    
    CGFloat duration = 0.4;
    self.curPointView.hidden = NO;
    self.extendBtn.hidden = NO;
    self.realCoordBtn.hidden = NO;
    self.addPointBtn.selected = NO;
    [self.addPointBtn setTitle:@"设为途径点" forState:UIControlStateNormal];
    [self.randomTimer setFireDate:[NSDate distantPast]];
    [UIView animateWithDuration:duration animations:^{
        [self updateRoutePathHeight:self.keyPoints.count];
        if (@available(iOS 11, *)) {
            UIEdgeInsets safeEdge = self.view.safeAreaInsets;
            self.routePathToping.constant = safeEdge.top + 44;
        } else {
            self.routePathToping.constant = 64;
        }
        self.startBtnWidth.constant = 94;
        self.startBtnHeight.constant = 40;
        self.addPointBtn.layer.cornerRadius = 20;
        self.routePathLeading.constant = 0;
        self.settingBtnTrailing.constant = -40;
        self.shareBtnTrailing.constant = -40;
        self.extendBtnLeading.constant = 12;
        self.showRealBtnLeading.constant = 12;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.shareBtn.hidden = YES;
        self.settingBtn.hidden = YES;
        [self showAllPointsAndRoute:NO];
    }];
    
    [self.routePathView closeFoldView];
    [self.routePathView configWithPoints:self.keyPoints];
}

- (void)onFinishSelecting
{
    if (self.keyPoints.count < 3) {
        [DNPromptView showToast:@"请至少选择两个路径点"];
    } else {
        [self stopRandomPrompt];
        [self finishSelectPoints];
    }
}

- (void)onEditPoints:(NSMutableArray *)keyPoints withChange:(BOOL)change
{    
    if (self.routePathView.isEditing) {
        self.shadeView.hidden = NO;
    } else {
        self.keyPoints = keyPoints;
        self.currentIndex = keyPoints.count + 1;
        [self showAllPointsAndRoute:NO];
    }
    
    if (change) {
        self.didEdited = YES;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        NSInteger count = self.keyPoints.count > 8 ? 8 : self.keyPoints.count;
        if (count < 5 || !self.routePathView.isEditing) {
            [self updateRoutePathHeight:count];
        } else {
            self.routePathHeight.constant = count * kPathCellHeight;
        }
        self.shadeView.alpha = self.routePathView.isEditing ? 1 : 0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (!self.routePathView.isEditing) {
            self.shadeView.hidden = YES;
        }
    }];
}

#pragma mark - DNRouteSettingViewDelegate

- (void)handleSettingResult:(DNRouteModel *)routeModel andRefresh:(BOOL)refresh
{
    self.distanceLabel.text = @"路线规划中...";
    if (refresh || self.routeDistance < 1) {
        [self showAllPointsAndRoute:YES];
    }
    [self updateIcons];
}

#pragma mark - DNPointRuleViewDelegate

- (void)onPointRuleChange:(DNPointRule)pointRule
{
    self.pointRule = pointRule;
}

#pragma mark - BMKMapViewDelegate

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
    newAnnotationView.centerOffset = CGPointMake(1, -15);
    newAnnotationView.animatesDrop = NO;// 设置该标注点动画显示
    if ([annotation.title isEqualToString:@"起"]) {
        newAnnotationView.image = [UIImage imageNamed:@"DNFeature.bundle/route_path_start"];
    } else if ([annotation.title isEqualToString:@"终"]) {
        newAnnotationView.image = [UIImage imageNamed:@"DNFeature.bundle/route_path_end"];
    } else {
        newAnnotationView.image = [UIImage imageNamed:@"DNFeature.bundle/route_path_point"];
    }
    
    CGSize imgSize = newAnnotationView.image.size;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, imgSize.width, imgSize.height*0.7)];
    titleLabel.text = annotation.title;
    titleLabel.font = DNFont12;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [newAnnotationView addSubview:titleLabel];
    return newAnnotationView;
}

- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (self.isClickEvent || self.routePathView.showFold) {
        self.isClickEvent = NO;
        return;
    }
    
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

- (BMKOverlayView*)mapView:(BMKMapView *)map viewForOverlay:(id<BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = [[UIColor alloc] initWithRed:0 green:1 blue:1 alpha:1];
        polylineView.strokeColor = DNColorFF549C;
        polylineView.lineWidth = 2;
        return polylineView;
    }
    return nil;
}

#pragma mark - BMKGeoCodeSearchDelegate

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeSearchResult *)result errorCode:(BMKSearchErrorCode)error
{
    if (result.location.latitude/1 == 0 || result.location.longitude/1 == 0) {
        return;
    }
    
    if (self.isClickEvent) {
        [self.mapView setCenterCoordinate:result.location animated:YES];
    }
    self.realCoordBtn.selected = NO;
    
    [self showCenterWithAnimate:YES];
    [self showPathForCoord:result.location withAddress:result.address];
}

#pragma mark - BMKRouteSearchDelegate

- (void)onGetDrivingRouteResult:(BMKRouteSearch*)searcher result:(BMKDrivingRouteResult*)result errorCode:(BMKSearchErrorCode)error
{
    if (error != BMK_SEARCH_NO_ERROR && result.routes.count > 0) {
        return ;
    }
    
    BMKRouteLine *routeLine = [result.routes objectAtIndex:0];
    [self handleResult:routeLine forSearch:searcher];
}

- (void)onGetWalkingRouteResult:(BMKRouteSearch*)searcher result:(BMKWalkingRouteResult*)result errorCode:(BMKSearchErrorCode)error
{
    if (error != BMK_SEARCH_NO_ERROR && result.routes.count > 0) {
        return ;
    }
    
    BMKRouteLine *routeLine = [result.routes objectAtIndex:0];
    [self handleResult:routeLine forSearch:searcher];
}

- (void)onGetRidingRouteResult:(BMKRouteSearch*)searcher result:(BMKRidingRouteResult*)result errorCode:(BMKSearchErrorCode)error
{
    if (error != BMK_SEARCH_NO_ERROR && result.routes.count > 0) {
        return ;
    }
    
    BMKRouteLine *routeLine = [result.routes objectAtIndex:0];
    [self handleResult:routeLine forSearch:searcher];
}

#pragma mark - Privates

- (void)layoutSettingView
{
    self.navigationView.hidden = YES;
    
    self.currentIndex = 1;
    self.isClickEvent = YES;
    self.mapView.delegate  = self;
    self.mapView.zoomLevel = 16;
    
    self.settingBtnTrailing.constant = -40;
    self.shareBtnTrailing.constant = -40;
    self.extendBtnLeading.constant = 12;
    self.showRealBtnLeading.constant = 12;
    
    [self updateIcons];
    
    [self.randomTimer setFireDate:[NSDate distantPast]];
    self.routePathView.delegate = self;
    self.addPointBtn.userInteractionEnabled = NO;
    self.pointRule = [[[NSUserDefaults standardUserDefaults] valueForKey:kNewPointRule] integerValue];
    
    if (self.realCoord.latitude != 0  && self.realCoord.longitude != 0) {
        BMKUserLocation *userLocation = [[BMKUserLocation alloc] init];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:self.realCoord.latitude
                                                          longitude:self.realCoord.longitude];
        userLocation.location = location;
        [self.mapView updateLocationData:userLocation];
        [self.mapView setCenterCoordinate:self.realCoord animated:YES];
    }
    
    UIImage *bgImg = [UIImage imageFromColor:DNColorD9D9D9];
    [self.extendBtn setBackgroundImage:bgImg forState:UIControlStateHighlighted];
    [self.realCoordBtn setBackgroundImage:bgImg forState:UIControlStateHighlighted];
    
    [self.addPointBtn setTitle:@"设为途径点" forState:UIControlStateNormal | UIControlStateHighlighted];
    [self.addPointBtn setTitle:@"开始模拟" forState:UIControlStateSelected | UIControlStateHighlighted];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSearchPoint:)
                                                 name:SelectSearchPoint
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleCollectionPath:)
                                                 name:kSelectRoutPath
                                               object:nil];
}

- (void)finishSelectPoints
{
    self.settingBtn.hidden = NO;
    self.shareBtn.hidden = NO;
    self.curPointView.hidden = YES;
    [self.keyPoints removeLastObject];
    self.currentIndex = self.keyPoints.count + 1;
    self.addPointBtn.selected = YES;
    [self.addPointBtn setTitle:@"开始模拟" forState:UIControlStateSelected];
    
    CGFloat duration = 0.4;
    [UIView animateWithDuration:duration animations:^{
        if (@available(iOS 11, *)) {
            UIEdgeInsets safeEdge = self.view.safeAreaInsets;
            self.routePathToping.constant = safeEdge.top;
        } else {
            self.routePathToping.constant = 20;
        }
        self.startBtnWidth.constant = 70;
        self.startBtnHeight.constant = 70;
        self.addPointBtn.layer.cornerRadius = 35;
        self.routePathHeight.constant = 74;
        self.routePathLeading.constant = 36;
        self.settingBtnTrailing.constant = 12;
        self.shareBtnTrailing.constant = 12;
        self.extendBtnLeading.constant = -40;
        self.showRealBtnLeading.constant = -40;
        [self.routePathView layoutIfNeeded];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.extendBtn.hidden = YES;
        self.realCoordBtn.hidden = YES;
        if (!self.everShowSetting) {
            self.everShowSetting = YES;
            [self onSettingDetail];
            
            [self showAllPointsAndRoute:NO];
        } else {
            [self showAllPointsAndRoute:YES];
        }
    }];
    [self.routePathView showFoldView:self.keyPoints];
}

- (void)startRoute
{
    if ([self.routeLines.allKeys count] == 0) {
        [[DNPromptView sharedInstance] showDetailText:@"路线异常，请重新规划路线后再试！" andRemove:1.2];
        return ;
    }
    self.routeModel.keyPoints = self.keyPoints;
    self.routeModel.routeLine = self.routeLines;
    self.routeModel.extendDic = @{@"distance": @(self.routeDistance)};
    [[DNFmdbUnit sharedInstance] dnInsertModel:self.routeModel withKey:@"bundleID"];
    
    NSDictionary *paramsDic = @{@"bundleID": self.routeModel.bundleID,
                                @"autoStart": @(1),
                                @"latitude": @(self.realCoord.latitude),
                                @"longitude": @(self.realCoord.longitude)};
    NSString *url = @"root/push/DNRouteNavigatingController";
    [[DNRouteManager sharedInstance] routeURLStr:url withParamsDic:paramsDic];
    [TalkingData trackEvent:kEventRoute label:kLabelRouteStart];
    
    [self onSelectPoint];
}

- (void)handleSearchPoint:(NSNotification *)notify
{
    self.isClickEvent = YES;
    
    CGFloat latitude  = [[notify.userInfo valueForKey:@"latitude"] floatValue];
    CGFloat longitude = [[notify.userInfo valueForKey:@"longitude"] floatValue];
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(latitude, longitude);
    BMKReverseGeoCodeSearchOption *geoOption = [[BMKReverseGeoCodeSearchOption alloc] init];
    geoOption.location = coord;
    [self.geoService reverseGeoCode:geoOption];
}

- (void)handleCollectionPath:(NSNotification *)notify
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *bundleID = [notify.userInfo valueForKey:@"bundleID"];
        if (bundleID) {
            self.didEdited = NO;
            self.routeModel = [[[DNFmdbUnit sharedInstance] dnSearchModel:[DNRouteModel class]
                                                                  withKey:@"bundleID"
                                                                 andValue:bundleID] firstObject];
            self.keyPoints = [NSMutableArray arrayWithArray:self.routeModel.keyPoints];
            self.isClickEvent = NO;
            self.currentIndex = self.keyPoints.count + 1;
            [self updateIcons];
            [self updateRoutePathHeight:self.keyPoints.count];
            [self.routePathView configWithPoints:self.keyPoints];
            [self showAllPointsAndRoute:NO];
            [self.addPointBtn setTitle:@"设为途径点" forState:UIControlStateNormal];
        }
    });
}

- (void)addAnnotationAtLocation:(CLLocationCoordinate2D)location
{
    if (!self.routePathView.showFold) {
        self.addPointBtn.userInteractionEnabled = NO;
        BMKReverseGeoCodeSearchOption* reverseOption = [[BMKReverseGeoCodeSearchOption alloc] init];
        reverseOption.location = location;
        [self.geoService reverseGeoCode:reverseOption];
    }
}

- (void)showCenterWithAnimate:(BOOL)animate
{
    self.addPointBtn.userInteractionEnabled = YES;
    
    CGPoint center = CGPointMake(self.mapView.center.x, self.mapView.frame.size.height/2 - 15);
    NSString *title = [NSString stringWithFormat:@"%ld", (long)self.currentIndex];
    if (self.currentIndex == 1) {
        title = @"起";
    }
    self.curPointView.title  = title;
    self.curPointView.center = center;
    
    if (animate) {
        CAKeyframeAnimation *anim = [CAKeyframeAnimation animation];
        anim.keyPath = @"position";
        anim.values = @[[NSValue valueWithCGPoint:CGPointMake(center.x, center.y)],
                        [NSValue valueWithCGPoint:CGPointMake(center.x, center.y-10)],
                        [NSValue valueWithCGPoint:CGPointMake(center.x, center.y)]];
        anim.duration = 0.5;
        [self.curPointView.layer addAnimation:anim forKey:nil];
    }
}

- (void)showAllPointsAndRoute:(BOOL)startRoute
{
    if (startRoute) {
        self.linesCount = 0;
        self.traificCount = 0;
        self.routeDistance = 0;
        [self.routeLines removeAllObjects];
    }
    NSArray* array = [NSArray arrayWithArray:self.mapView.annotations];
    [self.mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:self.mapView.overlays];
    [self.mapView removeOverlays:array];
    
    __block CGFloat minLatitude  = 500;
    __block CGFloat minLongitude = 500;
    __block CGFloat maxLatitude  = -500;
    __block CGFloat maxLongitude = -500;
    __block CLLocationCoordinate2D lastCoord = CLLocationCoordinate2DMake(0, 0);
    [self.keyPoints enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat latitude  = [[obj valueForKey:@"latitude"] floatValue];
        CGFloat longitude = [[obj valueForKey:@"longitude"] floatValue];
        if (latitude > maxLatitude) {
            maxLatitude = latitude;
        }
        if (longitude > maxLongitude) {
            maxLongitude = longitude;
        }
        if (latitude < minLatitude) {
            minLatitude = latitude;
        }
        if (longitude < minLongitude) {
            minLongitude = longitude;
        }
        
        // 在地图上显示各点的大头针
        CLLocationCoordinate2D newCoord = CLLocationCoordinate2DMake(latitude, longitude);
        NSString *index = [NSString stringWithFormat:@"%ld", (long)idx+1];
        if (idx == 0) {
            index = @"起";
        } else if (idx == self.keyPoints.count-1 && startRoute) {
            index = @"终";
        }
        BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
        item.title = index;
        item.coordinate = newCoord;
        [self.mapView addAnnotation:item];
        
        if (startRoute) {
            // 在地图上展示导航的路线
            if (!lastCoord.latitude) {
                lastCoord = newCoord;
                return ;
            }
            if (self.linesCount == 0 && self.routeModel.routeType != DNRouteTypeLine) {
                self.distanceLabel.text = @"路线规划中...";
                self.durationLabel.text = @"";
                [[DNPromptView sharedInstance] showLoadingText:@"路线规划中"];
            }
            
            self.linesCount++;
            [self routeFrom:lastCoord to:newCoord];
            lastCoord = newCoord;
        }
    }];
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((minLatitude + maxLatitude)/2.0,
                                                               (minLongitude + maxLongitude)/2.0);
    CLLocationDegrees latDelta = (center.latitude - minLatitude)*2.0;
    CLLocationDegrees lonDelta = (center.longitude - minLongitude)*2.0;
    BMKCoordinateSpan span = {fabs(latDelta)*1.5, fabs(lonDelta)*1.5};
    BMKCoordinateRegion region = {center, span};
    self.coordsRegion = region;
    if (!startRoute || self.routeModel.routeType == DNRouteTypeLine) {
        [self.mapView setRegion:self.coordsRegion animated:YES];
    }
}

// 根据用户设置，搜索从from到to两个节点之间的路线
- (void)routeFrom:(CLLocationCoordinate2D)from to:(CLLocationCoordinate2D)to
{
    BMKRouteSearch *routeSearch = [[BMKRouteSearch alloc] init];
    routeSearch.delegate = self;
    
    BMKPlanNode *fromNode = [[BMKPlanNode alloc] init];
    BMKPlanNode *toNode   = [[BMKPlanNode alloc] init];
    toNode.pt   = to;
    fromNode.pt = from;
    
    if (self.routeModel.routeType == DNRouteTypeCar) {
        BMKDrivingPolicy policy;
        if (self.routeModel.gpsRule == GPSRule_Traffic) {
            policy = BMK_DRIVING_BLK_FIRST;
        } else if (self.routeModel.gpsRule == GPSRule_Distance) {
            policy = BMK_DRIVING_DIS_FIRST;
        } else {
            policy = BMK_DRIVING_TIME_FIRST;
        }
        
        BMKDrivingRoutePlanOption *drivingOption = [[BMKDrivingRoutePlanOption alloc] init];
        drivingOption.to   = toNode;
        drivingOption.from = fromNode;
        drivingOption.drivingPolicy = policy;
        [routeSearch drivingSearch:drivingOption];
    }
    if (self.routeModel.routeType == DNRouteTypeWalk) {
        BMKWalkingRoutePlanOption *walkingOption = [[BMKWalkingRoutePlanOption alloc] init];
        walkingOption.to   = toNode;
        walkingOption.from = fromNode;
        [routeSearch walkingSearch:walkingOption];
    }
    if (self.routeModel.routeType == DNRouteTypeRide) {
        BMKRidingRoutePlanOption *ridingOption = [[BMKRidingRoutePlanOption alloc] init];
        ridingOption.to   = toNode;
        ridingOption.from = fromNode;
        [routeSearch ridingSearch:ridingOption];
    }
    if (self.routeModel.routeType == DNRouteTypeLine) {
        [self drawStraightLineFrom:from to:to];
    }
    [self.routeSearchArray addObject:routeSearch];
}

// 处理检索结果，获取路线的轨迹点
- (void)handleResult:(BMKRouteLine *)routeLine forSearch:(BMKRouteSearch *)searcher
{
    self.linesCount--;
    NSInteger routeIndex = 0;
    for (NSInteger i=0 ; i<[self.routeSearchArray count]; i++) {
        BMKRouteSearch* tmpSearcher = [self.routeSearchArray objectAtIndex:i];
        if (searcher == tmpSearcher) {
            routeIndex = i; break;
        }
    }
    
    NSInteger pointCount = 0;
    for (int i=0 ; i<[routeLine.steps count] ; i++) {
        BMKRouteStep *routeStep = [routeLine.steps objectAtIndex:i];
        pointCount += routeStep.pointsCount;
    }
    
    // 获取轨迹点
    NSInteger stepIndex = 0;
    CLLocationCoordinate2D stepCoordArray[pointCount];
    NSMutableArray *coordArray = [NSMutableArray array];
    for (int i=0 ; i<[routeLine.steps count] ; i++) {
        BMKRouteStep* routeStep = [routeLine.steps objectAtIndex:i];
        BOOL isTraffic = NO;
        NSString *entraceInstruction = [routeStep valueForKey:@"_entraceInstruction"];
        if (entraceInstruction && ([entraceInstruction rangeOfString:@"左转"].location != NSNotFound ||
                                   [entraceInstruction rangeOfString:@"右转"].location != NSNotFound)) {
            isTraffic = YES;
            self.traificCount++;
        }
        
        for(int j = 0; j<routeStep.pointsCount ; j++) {
            CLLocationCoordinate2D coord = BMKCoordinateForMapPoint(routeStep.points[j]);
            stepCoordArray[stepIndex++] = coord;
            
            NSDictionary* stemCoordDic = @{@"latitude":  @(coord.latitude),
                                           @"longitude": @(coord.longitude),
                                           @"isTraffic": (i>0 && j==0) ? @(isTraffic) : @"0"};
            NSString* stemCoordStr = [stemCoordDic convertToJSONString];
            [coordArray addObject:stemCoordStr];
        }
    }
    [self.routeLines setValue:coordArray forKey:[NSString stringWithFormat:@"%ld", (long)routeIndex]];
    
    // 通过points构建BMKPolyline
    BMKPolyline *polyLine = [BMKPolyline polylineWithCoordinates:stepCoordArray count:pointCount];
    [self.mapView addOverlay:polyLine]; // 添加路线overlay
    
    self.routeDistance += routeLine.distance;
    if (self.linesCount == 0) {
        [self showRouteDescription];
        [self.routeSearchArray removeAllObjects];
        [self.mapView setRegion:self.coordsRegion animated:YES];
    }
}

- (void)drawStraightLineFrom:(CLLocationCoordinate2D)from to:(CLLocationCoordinate2D)to
{
    CLLocationCoordinate2D stepCoordArray[2];
    stepCoordArray[0] = from;
    stepCoordArray[1] = to;
    
    // 通过points构建BMKPolyline
    BMKPolyline *polyLine = [BMKPolyline polylineWithCoordinates:stepCoordArray count:2];
    [self.mapView addOverlay:polyLine]; // 添加路线overlay
    
    NSDictionary *fromCoordDic = @{@"latitude":  @(from.latitude),
                                   @"longitude": @(from.longitude),
                                   @"isTraffic": @"0"};
    NSDictionary *toCoordDic = @{@"latitude":  @(to.latitude),
                                 @"longitude": @(to.longitude),
                                 @"isTraffic": @"0"};
    NSArray *coordArray = @[[fromCoordDic convertToJSONString], [toCoordDic convertToJSONString]];
    [self.routeLines setValue:coordArray forKey:[NSString stringWithFormat:@"%d", self.linesCount-1]];
    
    BMKMapPoint po1 = BMKMapPointForCoordinate(from);
    BMKMapPoint po2 = BMKMapPointForCoordinate(to);
    self.routeDistance += BMKMetersBetweenMapPoints(po1,po2);
    if (self.linesCount >= self.keyPoints.count -1) {
        [self showRouteDescription];
        self.linesCount = 0;
    }
}

- (void)updateRoutePathHeight:(NSInteger)count
{
    // 路线节点数量变更后，需要调整整个路线编辑视图的高度
    CGFloat height = (count < 3 ? 2.5 : count) * kPathCellHeight;
    CGFloat maxHeight = kPathCellHeight * 4;
    if ([UIScreen mainScreen].bounds.size.height <= 568) {
        maxHeight = kPathCellHeight * 3;
    }
    self.routePathHeight.constant = height > maxHeight ? maxHeight : height;
    [self.view layoutIfNeeded];
}

- (void)showRouteDescription
{
    [[DNPromptView sharedInstance] hideView:0.3];
    
    NSString *distance = [NSString stringWithFormat:@"全程%d米", self.routeDistance];
    if (self.routeDistance >= 1000) {
        distance = [NSString stringWithFormat:@"全程%.1f公里", self.routeDistance/1000.0];
    }
    if (self.routeDistance == 0) {
        distance = @"计算距离中...";
    }
    self.distanceLabel.text = distance;
    
    __block int speed = 0;
    [self.routeModel.speedList enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        DNRouteType routeType = [key integerValue];
        if (routeType == self.routeModel.routeType) {
            speed = [obj intValue];
            return ;
        }
    }];
    
    int routeDuration = (int)(self.routeDistance/(speed/3.6)) + self.traificCount*self.routeModel.waitTime;
    int seconds = routeDuration % 60;
    int minutes = (routeDuration / 60) % 60;
    int hours   = routeDuration / 3600;
    
    NSString *duration = @"";
    if (hours > 0 || minutes > 0 || seconds > 0) {
        duration = @"预计";
    }
    if (hours > 0) {
        duration = [duration stringByAppendingString:[NSString stringWithFormat:@"%d小时", hours]];
    }
    if (minutes > 0 || hours > 0) {
        duration = [duration stringByAppendingString:[NSString stringWithFormat:@"%d分", minutes]];
    }
    if (seconds > 0) {
        duration = [duration stringByAppendingString:[NSString stringWithFormat:@"%d秒", seconds]];
    }
    self.durationLabel.text = duration;
}

- (CAAnimation *)animation:(NSString *)keyPath values:(NSArray *)values duration:(CFTimeInterval)duration
{
    CAKeyframeAnimation *animate = [CAKeyframeAnimation animationWithKeyPath:keyPath];
    animate.values   = values;
    animate.duration = duration;
    animate.fillMode = kCAFillModeBoth;
    animate.removedOnCompletion = NO;
    return animate;
}

- (void)showPathForCoord:(CLLocationCoordinate2D)coord withAddress:(NSString *)address
{
    self.nowCoord = coord;
    
    NSDictionary *pointDic = @{@"latitude": @(coord.latitude),
                               @"longitude": @(coord.longitude),
                               @"address": address};
    if (self.keyPoints.count == 0) {
        [self.keyPoints addObject:pointDic];
    } else {
        if (self.currentIndex-1 > self.keyPoints.count) {
            self.currentIndex = self.keyPoints.count + 1;
        }
        self.keyPoints[self.currentIndex-1] = pointDic;
    }
    [self updateRoutePathHeight:self.keyPoints.count];
    [self.routePathView configWithPoints:self.keyPoints];
}

- (void)showRandomPrompt
{
    NSArray *promptList = @[@"可添加多个途径点，例如10个",
                            @"点击完成按钮，可结束选点开始路线规划",
                            @"长按途径点列表，可对途径点进行删除、排序",
                            @"点击右下角分享按钮，可分享路线给好友",
                            @"点击左下角扩展按钮，可修改新点生存规则",
                            @"点击右上角收藏按钮，可查看收藏的路线"];
    self.durationLabel.text = @"";
    
    NSString *prompt = promptList[(self.randomCount++)%promptList.count];
    if (self.randomCount > 1) {
        if (self.randomCount%2 == 0) {
            self.descriptionLabel.text = prompt;
            [UIView animateWithDuration:0.8 animations:^{
                self.distanceLabelToping.constant = -36;
                self.descriptionLabelToping.constant = 0;
                [[self.distanceLabel superview] layoutIfNeeded];
            } completion:^(BOOL finished) {
                self.distanceLabelToping.constant = 36;
            }];
        } else {
            self.distanceLabel.text = prompt;
            [UIView animateWithDuration:0.8 animations:^{
                self.distanceLabelToping.constant = 0;
                self.descriptionLabelToping.constant = -36;
                [[self.distanceLabel superview] layoutIfNeeded];
            } completion:^(BOOL finished) {
                self.descriptionLabelToping.constant = 36;
            }];
        }
    }
}

- (void)stopRandomPrompt
{
    self.randomCount = 1;
    [self.randomTimer setFireDate:[NSDate distantFuture]];
    self.distanceLabel.text = @"路线规划中...";
    if (self.distanceLabelToping.constant != 0) {
        [UIView animateWithDuration:0.5 animations:^{
            self.distanceLabelToping.constant = 0;
            self.descriptionLabelToping.constant = -36;
            [[self.distanceLabel superview] layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.descriptionLabelToping.constant = 36;
        }];
    }
}

- (void)updateIcons
{
    NSInteger routeType = self.routeModel.routeType;
    NSString *settingBtnImgName = [NSString stringWithFormat:@"DNFeature.bundle/map_setting_type_%ld", (long)routeType];
    [self.settingBtn  setImage:[UIImage imageNamed:settingBtnImgName] forState:UIControlStateNormal];
}

#pragma mark - Getters

- (NSMutableArray *)keyPoints
{
    if (!_keyPoints) {
        _keyPoints = [NSMutableArray array];
    }
    return _keyPoints;
}

- (BMKGeoCodeSearch *)geoService
{
    if (!_geoService) {
        _geoService = [[BMKGeoCodeSearch alloc] init];
        _geoService.delegate = self;
    }
    return _geoService;
}

- (UIView *)curPointView
{
    if (!_curPointView) {
        _curPointView = [[DNRoutePointView alloc] initWithFrame:CGRectMake(0, 0, 24, 31)];
        [self.mapView addSubview:_curPointView];
    }
    return _curPointView;
}

- (NSMutableArray *)routeSearchArray
{
    if (!_routeSearchArray) {
        _routeSearchArray = [NSMutableArray array];
    }
    return _routeSearchArray;
}

- (NSMutableDictionary *)routeLines
{
    if (!_routeLines) {
        _routeLines = [NSMutableDictionary dictionary];
    }
    return _routeLines;
}

- (DNRouteModel *)routeModel
{
    if (!_routeModel) {
        _routeModel = [[DNRouteModel alloc] init];
        NSInteger count = [[DNFmdbUnit sharedInstance] dnSearchModelArr:[DNRouteModel class]].count;
        _routeModel.bundleID = [NSString stringWithFormat:@"route%ld", (long)count+1];
    }
    return _routeModel;
}

- (DNRouteSettingView *)settingView
{
    if (!_settingView) {
        UINib  *nib = [UINib nibWithNibName:@"DNRouteSettingView" bundle:nil];
        _settingView = [[nib instantiateWithOwner:self options:nil] lastObject];
        _settingView.delegate = self;
        [self.view addSubview:_settingView];
        
        [_settingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.routePathView.mas_bottom);
            make.left.bottom.right.equalTo(self.view);
        }];
        [self.view layoutIfNeeded];
    }
    return _settingView;
}

- (DNPointRuleView *)pointRuleView
{
    if (!_pointRuleView) {
        
        UINib  *nib = [UINib nibWithNibName:@"DNPointRuleView" bundle:nil];
        _pointRuleView = [[nib instantiateWithOwner:self options:nil] lastObject];
        _pointRuleView.frame = [UIScreen mainScreen].bounds;
        _pointRuleView.delegate = self;
        [self.view addSubview:_pointRuleView];
        [self.view layoutIfNeeded];
    }
    return _pointRuleView;
}

- (NSTimer *)randomTimer
{
    if (!_randomTimer) {
        _randomTimer = [NSTimer timerWithTimeInterval:4
                                                target:self
                                              selector:@selector(showRandomPrompt)
                                              userInfo:nil
                                               repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_randomTimer forMode:NSRunLoopCommonModes];
    }
    return _randomTimer;
}

@end
