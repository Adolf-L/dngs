/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNRoutingWrapper.h
 *
 * Description  : DNRoutingWrapper
 *
 * Author       : eisen
 *
 * History      : Creation, 2018/7/3, Create the file
 *****************************************************************************************
 **/

#import "DNRoutingWrapper.h"
#import "DNRouteModel.h"
#import "BMKGeometry.h"
#import "DNFormatGps.h"
#import "DNGPSManager.h"

@interface DNRoutingInfo : NSObject
@property (nonatomic, strong) DNRouteModel *routeModel; //当前为哪个model模拟路线
@property (nonatomic, assign) BOOL pause;      //是否暂停
@property (nonatomic, assign) BOOL isFinish;   //是否完成
@property (nonatomic, assign) int  speed;      //当前速度
@property (nonatomic, assign) int  lineIndex;  //已经模拟过的路线标识
@property (nonatomic, assign) int  pointIndex; //已经模拟过的路线中点的标识
@property (nonatomic, assign) int  traific;    //已经等待的红灯时间
@property (nonatomic, assign) int  runTime;    //运行时间
@property (nonatomic, assign) int  distance;   //已移动的距离
@property (nonatomic, assign) CLLocationCoordinate2D lastCoord; //记录上一个模拟的点
@end
@implementation DNRoutingInfo
@end

@interface DNRoutingWrapper()

@property (nonatomic, strong) NSMutableArray *routerList;
@property (nonatomic, assign) int lastSpeed;

@property (nonatomic, assign) BOOL    isWorking;
@property (nonatomic, strong) NSTimer *routingTimer;

@end

@implementation DNRoutingWrapper

#pragma mark - Life cycle

+ (DNRoutingWrapper *)sharedInstance
{
    static DNRoutingWrapper *wrapper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        wrapper = [[DNRoutingWrapper alloc] init];
    });
    return wrapper;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self registerNotification];
    }
    return self;
}

#pragma mark - Public

- (void)startRouting:(DNRouteModel *)routeModel
{
    DNRoutingInfo *routingInfo = [[DNRoutingInfo alloc] init];
    routingInfo.routeModel = routeModel;
    routingInfo.lineIndex  = 0;
    routingInfo.pointIndex = 0;
    routingInfo.traific    = 1;
    routingInfo.runTime    = 0;
    routingInfo.distance   = 0;
    [self.routerList addObject:routingInfo];
    
    NSString* request = [NSString stringWithFormat:@"bundleID='%@'", routeModel.bundleID];
    [[DNFmdbUnit sharedInstance] dnUpdateModel:[DNRouteModel class] setKey:@"status" withValue:@(CurStatus_Working) andRequest:request];
    
    self.isWorking = YES;
    [self.routingTimer setFireDate:[NSDate distantPast]];
}

- (void)stopRouting:(NSString *)bundleID
{
    // 从routerList列表中删除当前routing任务
    BOOL curStatus = self.routingTimer.isValid;
    if (curStatus == YES) {
        [self.routingTimer setFireDate:[NSDate distantFuture]];
    }
    for (DNRoutingInfo *routingInfo in self.routerList) {
        if ([routingInfo.routeModel.bundleID isEqualToString:bundleID]) {
            [self.routerList removeObject:routingInfo];
            break;
        }
    }
    if (curStatus == YES) {
        [self.routingTimer setFireDate:[NSDate distantPast]];
    }
    
    // 修改数据库的数据
    NSString* request = [NSString stringWithFormat:@"bundleID='%@'", bundleID];
    [[DNFmdbUnit sharedInstance] dnUpdateModel:[DNRouteModel class]
                                        setKey:@"status"
                                     withValue:@(CurStatus_Close)
                                    andRequest:request];
}

- (void)setPause:(BOOL)pause
{
    for (DNRoutingInfo *routingInfo in self.routerList) {
        routingInfo.pause = pause;
    }
}

- (DNRoutingStatus)getRoutingStatus
{
    if (!self.routingTimer.isValid) {
        return DNRoutingStop;
    }
    
    DNRoutingStatus ret = DNRoutingStop;
    for (DNRoutingInfo *routingInfo in self.routerList) {
        if (routingInfo.pause) {
            ret = DNRoutingPaused;
            break;
        } else {
            ret = DNRoutingWorking;
        }
    }
    return ret;
}

- (BOOL)isWorking
{
    return _isWorking;
}

#pragma mark - Privates

- (void)registerNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminate:)
                                                 name:@"UIApplicationWillTerminateNotification"
                                               object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self.routingTimer invalidate];
    for (DNRoutingInfo *routingInfo in self.routerList) {
        NSString *bundleID = routingInfo.routeModel.bundleID;
        NSString* request = [NSString stringWithFormat:@"bundleID='%@'", bundleID];
        [[DNFmdbUnit sharedInstance] dnUpdateModel:[DNRouteModel class]
                                            setKey:@"status"
                                         withValue:@(CurStatus_Close)
                                        andRequest:request];
    }
}

- (void)handleRouting
{
    for (DNRoutingInfo *routingInfo in self.routerList) {
        if (routingInfo.pause) {
            continue;
        }
        
        DNRouteModel *routeModel = routingInfo.routeModel;
        NSString *routeType = [NSString stringWithFormat:@"%ld", (long)routeModel.routeType];
        int speed = [[routeModel.speedList valueForKey:routeType] intValue];
        int waitTime = routeModel.waitTime; //红灯等待时间
        
        if (routingInfo.lineIndex < routeModel.keyPoints.count -1) {
            // 计时器加1
            routingInfo.runTime += 1;
            // 获取当前线路的所有节点
            NSString *lineIndexKey = [NSString stringWithFormat:@"%d", routingInfo.lineIndex];
            NSArray *coordArray = [routeModel.routeLine valueForKey:lineIndexKey];
            
            // 模拟路线中所有的节点
            if (routingInfo.pointIndex < coordArray.count) {
                NSString     *coordStr = coordArray[routingInfo.pointIndex];
                NSDictionary *coordDic = [NSDictionary dictionaryWithJsonString:coordStr];
                BOOL    isTraffic = [[coordDic valueForKey:@"isTraffic"] boolValue];
                CGFloat latitude  = [[coordDic valueForKey:@"latitude"] floatValue];
                CGFloat longitude = [[coordDic valueForKey:@"longitude"] floatValue];
                CLLocationCoordinate2D curCoord = CLLocationCoordinate2DMake(latitude, longitude);
                
                // 第一条路线的第一个点，需要设置为路线模拟起始点
                if (routingInfo.pointIndex == 0) {
                    routingInfo.pointIndex += 1;
                    routingInfo.lastCoord = curCoord;
                    [self saveRoutePoint:curCoord withInfo:routingInfo];
                    continue;
                }
                
                BMKMapPoint po1 = BMKMapPointForCoordinate(routingInfo.lastCoord);
                BMKMapPoint po2 = BMKMapPointForCoordinate(curCoord);
                CLLocationDistance distance = BMKMetersBetweenMapPoints(po1, po2);
                
                BOOL randomSpeed = (routeModel.routeType == DNRouteTypeCar || routeModel.routeType == DNRouteTypeRide);
                if (randomSpeed && routingInfo.lineIndex == 0 && routingInfo.speed < speed * 0.9) {
                    speed = [self getStartSpeed:routingInfo.speed withMaxSpeed:speed];
                } else if (randomSpeed &&
                           routingInfo.lineIndex == routeModel.keyPoints.count - 2 &&
                           routingInfo.pointIndex == coordArray.count - 1 &&
                           distance < 120) {
                    speed = [self getStopSpeed:routingInfo.speed withMaxSpeed:speed];
                } else {
                    speed = [self getCurrentSpeed:speed];
                }
                routingInfo.speed = speed;
                
                int space = (speed ? : 5)/3.6;      //每秒钟的移动距离(单位:米)
                if (distance <= space) {
                    // 两个关键节点之间的距离小于space
                    if (isTraffic) {
                        if (routingInfo.traific == 1) {
                            routingInfo.distance += distance;
                        }
                        if (routingInfo.traific < waitTime+1) {
                            routingInfo.traific += 1;
                            [self saveRoutePoint:curCoord withInfo:routingInfo];
                            continue; //等待红灯
                        } else {
                            routingInfo.traific = 1;
                            [self saveRoutePoint:curCoord withInfo:routingInfo];
                        }
                    } else {
                        routingInfo.distance += distance;
                        [self saveRoutePoint:curCoord withInfo:routingInfo];
                    }
                    routingInfo.pointIndex += 1;
                    routingInfo.lastCoord  = curCoord;
                    
                    if (routingInfo.pointIndex >= coordArray.count) {
                        routingInfo.lineIndex += 1;
                        routingInfo.pointIndex = 1;
                    }
                    continue; //两个点间距小于space，直接模拟
                } else {
                    CGFloat unit = space/distance;
                    CGFloat offsetLat = (curCoord.latitude - routingInfo.lastCoord.latitude)*unit;
                    CGFloat offsetLon = (curCoord.longitude - routingInfo.lastCoord.longitude)*unit;
                    
                    CGFloat newLat = routingInfo.lastCoord.latitude + offsetLat;
                    CGFloat newLon = routingInfo.lastCoord.longitude + offsetLon;
                    CLLocationCoordinate2D newCoord = CLLocationCoordinate2DMake(newLat, newLon);
                    
                    routingInfo.distance += space;
                    routingInfo.lastCoord = newCoord;
                    [self saveRoutePoint:newCoord withInfo:routingInfo];
                }
            } else {
                routingInfo.lineIndex += 1;
                routingInfo.pointIndex = 1;
            }
        } else {
            if (routeModel.routeRule == RouteRule_Circle) {
                routingInfo.traific = 1;
                routingInfo.distance = 0;
                routingInfo.pointIndex = 0;
                routingInfo.lineIndex  = 0;
                routingInfo.routeModel = [self reverseRoutePath:routingInfo.routeModel];
            } else {
                CurStatus status = CurStatus_Close;
                NSString* request = [NSString stringWithFormat:@"bundleID='%@'", routeModel.bundleID];
                if (routeModel.routeRule == RouteRule_Stay) {
                    status = CurStatus_Open;
                }
                [[DNFmdbUnit sharedInstance] dnUpdateModel:[DNRouteModel class]
                                                    setKey:@"status"
                                                 withValue:@(status)
                                                andRequest:request];
                routingInfo.isFinish = 1;
                [self saveRoutePoint:routingInfo.lastCoord withInfo:routingInfo];
                [self.routerList removeObject:routingInfo];
                break;
            }
        }
    }
    if (self.routerList.count == 0) {
        self.isWorking = NO;
        [self.routingTimer setFireDate:[NSDate distantFuture]];
        [[NSNotificationCenter defaultCenter] postNotificationName:RoutingWrapperStoped
                                                            object:nil
                                                          userInfo:nil];
    }
}

- (void)saveRoutePoint:(CLLocationCoordinate2D)baiduCoord withInfo:(DNRoutingInfo *)routingInfo
{
    CLLocationCoordinate2D gcjCoord = [[DNFormatGps sharedIntances] baiduGpsToGCJ:baiduCoord];
    CLLocationCoordinate2D gpsCoord = [[DNFormatGps sharedIntances] gcjToGPS:gcjCoord];
    if (routingInfo.isFinish && routingInfo.routeModel.routeRule == RouteRule_Stay) {
        [[DNGPSManager sharedInstance] workWithCoord:gpsCoord];
    } else {
        [[DNGPSManager sharedInstance] workWithCoord:gpsCoord andSpeed:routingInfo.speed];
    }
    
    NSDictionary *userInfo = @{@"bundleID": routingInfo.routeModel.bundleID,
                               @"latitude": @(baiduCoord.latitude),
                               @"longitude": @(baiduCoord.longitude),
                               @"speed": @(routingInfo.speed),
                               @"distance": @(routingInfo.distance),
                               @"runTime": @(routingInfo.runTime),
                               @"traific": @(routingInfo.traific),
                               @"isFinish": @(routingInfo.isFinish)};
    [[NSNotificationCenter defaultCenter] postNotificationName:RouteNavigatingInfo
                                                        object:nil
                                                      userInfo:userInfo];
    if (1 == routingInfo.isFinish) {
        [[NSNotificationCenter defaultCenter] postNotificationName:RouteNavigatingFinish
                                                            object:nil
                                                          userInfo:userInfo];
    }
}

- (int)getStartSpeed:(int)lastSpeed withMaxSpeed:(int)maxSpeed
{
    if (lastSpeed < 10) {
        return 10;
    }
    
    int retSpeed = lastSpeed;
    if (maxSpeed < 101) {
        retSpeed = lastSpeed + 10;
        if (maxSpeed - retSpeed < 10) {
            retSpeed = maxSpeed;
        }
    } else {
        retSpeed = lastSpeed + 25;
        if (maxSpeed - retSpeed < 25) {
            retSpeed = maxSpeed;
        }
    }
    return retSpeed;
}

- (int)getStopSpeed:(int)lastSpeed withMaxSpeed:(int)maxSpeed
{
    if (lastSpeed < 10) {
        return 10;
    }
    
    int retSpeed = lastSpeed;
    if (maxSpeed < 101) {
        retSpeed = lastSpeed - 10;
        if (retSpeed < 10) {
            retSpeed = 10;
        }
    } else {
        retSpeed = lastSpeed - 25;
        if (retSpeed < 25) {
            retSpeed = 10;
        }
    }
    
    return retSpeed;
}

- (int)getCurrentSpeed:(int)speed
{
    static int nCount = 0;
    if (nCount++ < 5) {
        return self.lastSpeed == 0 ? speed : self.lastSpeed;
    }
    nCount = 0;
    int unit = (int)(speed * 0.1);
    self.lastSpeed = speed + arc4random() % (unit * 2 + 1) - unit;
    return self.lastSpeed;
}

- (DNRouteModel *)reverseRoutePath:(DNRouteModel *)routeModel
{
    routeModel.keyPoints = [[routeModel.keyPoints reverseObjectEnumerator] allObjects];
    NSMutableDictionary *routeLine = [NSMutableDictionary dictionary];
    for (int i=0 ; i<routeModel.keyPoints.count-1 ; i++) {
        NSString *lineKey = [NSString stringWithFormat:@"%d", i];
        NSArray *coordArray = [routeModel.routeLine valueForKey:lineKey];
        if (coordArray.count > 0) {
            NSArray *newCoordArray = [[coordArray reverseObjectEnumerator] allObjects];
            NSInteger newIndex = routeModel.keyPoints.count - i - 2;
            NSString *newKey = [NSString stringWithFormat:@"%ld", (long)newIndex];
            [routeLine setValue:newCoordArray forKey:newKey];
        }
    }
    routeModel.routeLine = routeLine;
    return routeModel;
}

#pragma mark - Getters

- (NSMutableArray *)routerList
{
    if (!_routerList) {
        _routerList = [NSMutableArray array];
    }
    return _routerList;
}

- (NSTimer *)routingTimer
{
    if (!_routingTimer) {
        _routingTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(handleRouting) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_routingTimer forMode:NSDefaultRunLoopMode];
    }
    return _routingTimer;
}

@end
