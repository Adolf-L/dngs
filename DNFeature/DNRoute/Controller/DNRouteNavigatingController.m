/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNRouteNavigatingController.m
 *
 * Description  : DNRouteNavigatingController
 *
 * Author       : eisen
 *
 * History      : Creation, 2018/7/3, Create the file
 *****************************************************************************************
 **/

#import "DNRouteNavigatingController.h"
#import "TalkingData.h"
#import "BMKMapView.h"
#import "BMKPolyline.h"
#import "BMKGeometry.h"
#import "BMKPolylineView.h"
#import "BMKPointAnnotation.h"
#import "BMKPinAnnotationView.h"
#import "DNRouteModel.h"
#import "DNRoutingWrapper.h"
#import "DNCollectionUnit.h"
#import "DNGPSManager.h"

@interface DNRouteNavigatingController ()<BMKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *titleImgView;
@property (weak, nonatomic) IBOutlet UIView      *noHardwareView;
@property (weak, nonatomic) IBOutlet BMKMapView  *mapView;
@property (weak, nonatomic) IBOutlet UIButton    *pauseBtn;
@property (weak, nonatomic) IBOutlet UIButton    *angleBtn;
@property (weak, nonatomic) IBOutlet UIButton    *stopBtn;
@property (weak, nonatomic) IBOutlet UIButton    *collectBtn;
@property (weak, nonatomic) IBOutlet UILabel     *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel     *routeTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel     *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel     *waitTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel     *routeRuleLabel;
@property (weak, nonatomic) IBOutlet UILabel     *waitingLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelToping;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *routeInfoBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noHardwareToping;

@property (nonatomic, assign) CLLocationCoordinate2D realCoord;
@property (nonatomic, assign) BOOL               autoStart;
@property (nonatomic, assign) BOOL               showCurAngle; //是否展示当前视角
@property (nonatomic, strong) NSString           *bundleID;
@property (nonatomic, strong) DNRouteModel       *routeModel;
@property (nonatomic, strong) BMKPointAnnotation *pointAnnotation;

@end

@implementation DNRouteNavigatingController

#pragma mark - Life cycle

- (void)configWithParams:(NSDictionary *)params
{
    self.bundleID = [params valueForKey:@"bundleID"];
    self.autoStart = [[params valueForKey:@"autoStart"] boolValue];
    CGFloat latitude  = [[params valueForKey:@"latitude"] floatValue];
    CGFloat longitude = [[params valueForKey:@"longitude"] floatValue];
    if (latitude != 0 && longitude != 0) {
        self.realCoord = CLLocationCoordinate2DMake(latitude, longitude);
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mapView.delegate  = self;
    self.mapView.zoomLevel = 16;
    
    if ([[DNGPSManager sharedInstance] isConnecting]) {
        self.noHardwareView.hidden = YES;
    }
    
    UIImage *bgImg = [UIImage imageFromColor:DNColorD9D9D9];
    [self.pauseBtn setBackgroundImage:bgImg forState:UIControlStateHighlighted];
    [self.angleBtn setBackgroundImage:bgImg forState:UIControlStateHighlighted];
    [self.collectBtn setBackgroundImage:bgImg forState:UIControlStateHighlighted];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNavigatingInfo:)
                                                 name:RouteNavigatingInfo
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideNoHardwareView)
                                                 name:kGPSDidConnectNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showNoHardwareView)
                                                 name:kGPSDidDisconnectNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleGPSCMDNotification:)
                                                 name:kGPSCMDNotification
                                               object:nil];
    
    self.routeModel = [[[DNFmdbUnit sharedInstance] dnSearchModel:[DNRouteModel class]
                                                          withKey:@"bundleID"
                                                         andValue:self.bundleID] firstObject];
    NSArray *collectionArray = [[NSUserDefaults standardUserDefaults] objectForKey:kRouteLineCollection];
    [collectionArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *bundleID = [obj valueForKey:@"bundleID"];
        if ([self.routeModel.bundleID isEqualToString:bundleID]) {
            self.collectBtn.selected = YES;
            *stop = YES;
        }
    }];
}

- (void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
    
    if (@available(iOS 11, *)) {
        UIEdgeInsets safeEdge = self.view.safeAreaInsets;
        self.routeInfoBottom.constant = safeEdge.bottom;
        self.titleLabelToping.constant = safeEdge.top;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }

    self.mapView.showsUserLocation = YES;
    [self showRealCoord];
    [self layoutNavigatingView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self markKeyPoints];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self drawRouteLines];
        if (self.autoStart) {
            [[DNRoutingWrapper sharedInstance] startRouting:self.routeModel];
        }
    });
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    self.mapView.showsUserLocation = NO;
}

#pragma mark - Actions

- (IBAction)actionBack:(id)sender
{
    DNRoutingStatus routingStatus = [[DNRoutingWrapper sharedInstance] getRoutingStatus];
    if (routingStatus == DNRoutingStop) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    [DNAlertView showAlert:@"如果退出当前页面，将会强制停止当前路线模拟！"
                   message:nil
                firstTitle:@"取消"
               firstAction:nil
               secondTitle:@"强制停止"
              secondAction:^{
                  [[DNRoutingWrapper sharedInstance] stopRouting:self.routeModel.bundleID];
                  [[DNPromptView sharedInstance] showText:@"路线模拟已停止运行" andRemove:1.0];
                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                      [self.navigationController popViewControllerAnimated:YES];
                  });
              }];
}

- (IBAction)onCollectRouteLine:(UIButton *)sender
{
    if (sender.selected) {
        [DNPromptView showToast:@"路线已存在，无法重复收藏"];
    } else {
        sender.selected = YES;
        if (DNCollectOK == [DNCollectionUnit collectRouteLine:self.routeModel.bundleID]) {
            [DNPromptView showToast:@"路线收藏成功！"];
            [TalkingData trackEvent:kEventRoute label:kLabelRouteCollect];
        } else {
            [DNPromptView showToast:@"路线已存在，无法重复收藏"];
        }
    }
}

- (IBAction)onChangePauseStatus:(UIButton *)sender
{
    DNRoutingStatus routingStatus = [[DNRoutingWrapper sharedInstance] getRoutingStatus];
    if (routingStatus == DNRoutingStop) {
        [DNPromptView showToast:@"路线模拟已结束"];
        return;
    }
    
    sender.selected = !sender.selected;
    [[DNRoutingWrapper sharedInstance] setPause:sender.selected];
    if (sender.selected) {
        [DNPromptView showToast:@"暂停"];
    } else {
        [DNPromptView showToast:@"继续"];
    }
}

- (IBAction)onChangeAngleStatus:(UIButton *)sender
{
    DNRoutingStatus routingStatus = [[DNRoutingWrapper sharedInstance] getRoutingStatus];
    if (routingStatus == DNRoutingStop) {
        [DNPromptView showToast:@"路线模拟已结束"];
        return;
    }
    
    sender.selected = !sender.selected;
    self.showCurAngle = sender.selected;
    if (sender.selected) {
        [DNPromptView showToast:@"锁定视角"];
    } else {
        [DNPromptView showToast:@"自由视角"];
    }
}
- (IBAction)onStopNavigating:(UIButton *)sender
{
    [DNAlertView showAlert:@"确认停止当前路线模拟？"
                   message:nil
                firstTitle:@"取消"
               firstAction:nil
               secondTitle:@"确认"
              secondAction:^{
                  [[DNRoutingWrapper sharedInstance] stopRouting:self.routeModel.bundleID];
                  [[DNPromptView sharedInstance] showText:@"路线模拟已停止运行" andRemove:1.0];
                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                      [self.navigationController popViewControllerAnimated:YES];
                  });
              }];
}
- (IBAction)gotoWebsite:(UITapGestureRecognizer *)sender
{
    [[DNRouteManager sharedInstance] gotoWebsite:kDNGPSWebsite];
}

#pragma mark - BMKMapViewDelegate

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    customView.backgroundColor = [UIColor orangeColor];
    
    BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
    newAnnotationView.animatesDrop = NO;// 设置该标注点动画显示
    if (annotation == self.pointAnnotation) {
        newAnnotationView.image = [UIImage imageNamed:@"DNFeature.bundle/route_navigating_curcoord"];
        newAnnotationView.centerOffset = CGPointMake(1, -4);
    } else {
        newAnnotationView.centerOffset = CGPointMake(0, 0);
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
    }
    return newAnnotationView;
}

- (BMKOverlayView*)mapView:(BMKMapView *)map viewForOverlay:(id<BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView *polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = [[UIColor alloc] initWithRed:0 green:1 blue:1 alpha:1];
        polylineView.strokeColor = DNColorFF549C;
        polylineView.lineWidth = 2;
        return polylineView;
    }
    return nil;
}

#pragma mark - Privates

- (void)layoutNavigatingView
{
    NSString *type = [NSString stringWithFormat:@"%ld", (long)self.routeModel.routeType];
    NSString *imgName = [NSString stringWithFormat:@"DNFeature.bundle/route_type_%@", type];
    self.titleImgView.image = [UIImage imageNamed:imgName];
    
    self.waitTimeLabel.text = [NSString stringWithFormat:@"红灯停留%ds", self.routeModel.waitTime];
    self.routeRuleLabel.text = [self.routeModel obtainRouteRule];
    
    UIImage *backgroundImg = [UIImage imageFromColor:DNColorD9D9D9];
    [self.pauseBtn setBackgroundImage:backgroundImg forState:UIControlStateHighlighted];
    [self.angleBtn setBackgroundImage:backgroundImg forState:UIControlStateHighlighted];
}

- (void)handleGPSCMDNotification:(NSNotification *)notify
{
    BOOL pause = [[notify.userInfo valueForKey:@"pause"] boolValue];
    self.pauseBtn.selected = pause;
    [[DNRoutingWrapper sharedInstance] setPause:pause];
}

- (void)showRealCoord
{
    [self.mapView removeAnnotation:self.pointAnnotation];
    self.pointAnnotation.coordinate = self.realCoord;
    [self.mapView addAnnotation:self.pointAnnotation];
    
    BMKUserLocation *userLocation = [[BMKUserLocation alloc] init];
    userLocation.location = [[CLLocation alloc] initWithLatitude:self.realCoord.latitude
                                                       longitude:self.realCoord.longitude];
    [self.mapView updateLocationData:userLocation];
    
    NSMutableArray *points = [NSMutableArray arrayWithArray:self.routeModel.keyPoints];
    [points addObject:@{@"latitude": @(self.realCoord.latitude),
                        @"longitude": @(self.realCoord.longitude)}];
    [self showPreviewOfPoints:points];
}

- (void)markKeyPoints
{
    __block CGFloat minLatitude  = 500;
    __block CGFloat minLongitude = 500;
    __block CGFloat maxLatitude  = -500;
    __block CGFloat maxLongitude = -500;
    [self.routeModel.keyPoints enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *pathDic = (NSDictionary *)obj;
        CGFloat latitude  = [[pathDic valueForKey:@"latitude"] floatValue];
        CGFloat longitude = [[pathDic valueForKey:@"longitude"] floatValue];
        if (latitude == 0 && longitude == 0) {
            return ;
        }
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
        
        // 在地图上为各个节点添加标注
        CLLocationCoordinate2D newCoord = CLLocationCoordinate2DMake(latitude, longitude);
        BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
        if (idx == 0) {
            item.title = @"起";
        } else if (idx == self.routeModel.keyPoints.count-1) {
            item.title = @"终";
        } else {
            item.title = [NSString stringWithFormat:@"%d", (int)idx+1];
        }
        item.coordinate = newCoord;
        [self.mapView addAnnotation:item];
    }];
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((minLatitude + maxLatitude)/2.0,
                                                               (minLongitude + maxLongitude)/2.0);
    CLLocationDegrees latDelta = (center.latitude - minLatitude)*2.0;
    CLLocationDegrees lonDelta = (center.longitude - minLongitude)*2.0;
    BMKCoordinateSpan span = {fabs(latDelta)*1.6, fabs(lonDelta)*1.6};
    BMKCoordinateRegion region = {center, span};
    [self.mapView setRegion:region animated:YES];
}

- (void)drawRouteLines
{
    [self.routeModel.routeLine enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSArray *coordArray = obj;
        CLLocationCoordinate2D stepCoordArray[coordArray.count];
        for (int i=0 ; i<coordArray.count ; i++) {
            NSDictionary *coordDic = [NSDictionary dictionaryWithJsonString:coordArray[i]];
            CGFloat latitude  = [[coordDic valueForKey:@"latitude"] floatValue];
            CGFloat longitude = [[coordDic valueForKey:@"longitude"] floatValue];
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(latitude, longitude);
            stepCoordArray[i] = coord;
        }
        
        // 通过points构建BMKPolyline
        BMKPolyline *polyLine = [BMKPolyline polylineWithCoordinates:stepCoordArray count:coordArray.count];
        [self.mapView addOverlay:polyLine]; // 添加路线overlay
    }];
}

- (void)handleNavigatingInfo:(NSNotification *)notify
{
    NSString *bundleID = [notify.userInfo valueForKey:@"bundleID"];
    if (![bundleID isEqualToString:self.routeModel.bundleID]) {
        return;
    }
    
    CGFloat latitude  = [[notify.userInfo valueForKey:@"latitude"] floatValue];
    CGFloat longitude = [[notify.userInfo valueForKey:@"longitude"] floatValue];
    if (latitude != 0 && longitude != 0) {
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(latitude, longitude);
        [self.mapView removeAnnotation:self.pointAnnotation];
        self.pointAnnotation.coordinate = coord;
        [self.mapView addAnnotation:self.pointAnnotation];
        
        if (self.showCurAngle) {
            [self.mapView setCenterCoordinate:coord animated:YES];
        }
    }
    
    int speed = [[notify.userInfo valueForKey:@"speed"] intValue];
    self.speedLabel.text = [NSString stringWithFormat:@"速度%dkm/h", speed];
    
    BOOL isFinish = [[notify.userInfo valueForKey:@"isFinish"] boolValue];
    if (isFinish && self.routeModel.routeRule == RouteRule_Stop) {
        [self showRealCoord];
    }
    
    [self showDistanceAndTime:notify.userInfo];
}

- (void)showDistanceAndTime:(NSDictionary *)userInfo
{
    int runTime  = [[userInfo valueForKey:@"runTime"] intValue];
    int traific  = [[userInfo valueForKey:@"traific"] intValue];
    int distance = [[userInfo valueForKey:@"distance"] intValue];
    BOOL isFinish = [[userInfo valueForKey:@"isFinish"] boolValue];
    distance = [[self.routeModel.extendDic valueForKey:@"distance"] intValue] - distance;
    distance = distance > 0 ? distance : 0;
    
    // 设置红灯停留中
    self.waitingLabel.hidden = (traific == 1);
    if (traific != 1) {
        self.speedLabel.text = @"速度0km/h";
    }
    
    NSString *distanceStr = [NSString stringWithFormat:@"剩余%.1f公里", distance/1000.0];
    if (distance < 1000) {
        distanceStr = [NSString stringWithFormat:@"剩余%d米", distance];
    }
    if (isFinish) {
        distanceStr = @"到达终点";
        self.waitingLabel.hidden = YES;
        
        NSString *type = [NSString stringWithFormat:@"%ld", (long)self.routeModel.routeType];
        int speed = [[self.routeModel.speedList valueForKey:type] intValue];
        self.speedLabel.text = [NSString stringWithFormat:@"均速%dkm/h", speed];
    }
    self.distanceLabel.text = distanceStr;
    
    int seconds = runTime % 60;
    int minutes = (runTime / 60) % 60;
    int hours   = runTime / 3600;
    
    NSString *duration = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    if (hours > 0) {
        duration = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    }
    if (isFinish) {
        duration = [@"运行时长" stringByAppendingString:duration];
    }
    self.routeTimeLabel.text = duration;
}

- (void)stopRoutePath
{
    [DNAlertView showAlert:@"确认终止当前模拟路线？"
                   message:nil
                firstTitle:@"取消"
               firstAction:nil
               secondTitle:@"确认"
              secondAction:^(UIAlertAction * _Nullable action) {
                  [[DNRoutingWrapper sharedInstance] stopRouting:self.routeModel.bundleID];
                  [[DNPromptView sharedInstance] showText:@"已终止路线模拟" andRemove:1.2];
                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                      [self.navigationController popViewControllerAnimated:YES];
                  });
              }];
}

- (void)showPreviewOfPoints:(NSArray *)points
{
    __block CGFloat minLatitude  = 500;
    __block CGFloat minLongitude = 500;
    __block CGFloat maxLatitude  = -500;
    __block CGFloat maxLongitude = -500;
    [points enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *pathDic = (NSDictionary *)obj;
        CGFloat latitude  = [[pathDic valueForKey:@"latitude"] floatValue];
        CGFloat longitude = [[pathDic valueForKey:@"longitude"] floatValue];
        if (latitude == 0 && longitude == 0) {
            return ;
        }
        
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
    }];
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((minLatitude + maxLatitude)/2.0,
                                                               (minLongitude + maxLongitude)/2.0);
    CLLocationDegrees latDelta = (center.latitude - minLatitude)*2.0;
    CLLocationDegrees lonDelta = (center.longitude - minLongitude)*2.0;
    BMKCoordinateSpan span = {fabs(latDelta)*1.4, fabs(lonDelta)*1.4};
    BMKCoordinateRegion region = {center, span};
    [self.mapView setRegion:region animated:YES];
}

- (void)showNoHardwareView
{
    self.noHardwareView.hidden = NO;
}

- (void)hideNoHardwareView
{
    self.noHardwareView.hidden = YES;
}

#pragma mark - Getters

- (BMKPointAnnotation *)pointAnnotation
{
    if (!_pointAnnotation) {
        _pointAnnotation = [[BMKPointAnnotation alloc] init];
    }
    return _pointAnnotation;
}

@end
