//
//  DNGPSManager.m
//  AVOSCloud
//
//  Created by eisen.chen on 2018/9/12.
//

#import "DNGPSManager.h"
#import "TalkingData.h"
#import "DNRoutingWrapper.h"
#import "NSData+XOREncrypt.h"
#import <ExternalAccessory/ExternalAccessory.h>

@interface DNGPSManager()<NSStreamDelegate, EAAccessoryDelegate>

@property (nonatomic, strong) EAAccessory *nvcAccessory;
@property (nonatomic, strong) EASession   *nvcSession;
@property (nonatomic, strong) NSTimer     *workingTimer;

@property (nonatomic, assign) CLLocationCoordinate2D globalCoord;
@property (nonatomic, assign) CLLocationCoordinate2D lastCoord;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateFormatter *dateFormatter2;

@property (nonatomic, assign) BOOL        didLoadGPS;
@property (nonatomic, assign) BOOL        isRetryForFail;
@property (nonatomic, assign) BOOL        receivedACK;
@property (nonatomic, assign) BOOL        isFromGlobal;
@property (nonatomic, assign) BOOL        isConnectOK;
@property (nonatomic, assign) NSInteger   retryCount;

@end

@implementation DNGPSManager

#pragma mark - Life cycle

+ (DNGPSManager *)sharedInstance
{
    static DNGPSManager *gpsManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gpsManager = [[DNGPSManager alloc] init];
    });
    return gpsManager;
}

- (void)dealloc
{
    [self closeSession];
    [[EAAccessoryManager sharedAccessoryManager] unregisterForLocalNotifications];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 进入APP后先检测是否已经有硬件连接
        self.receivedACK = YES;
        [self startConnecting];
    }
    return self;
}

#pragma mark - Public

- (void)checkConnecting
{
    [self startConnecting];
}

- (BOOL)isConnecting
{
    return self.isConnectOK;
}

- (void)workWithCoord:(CLLocationCoordinate2D)coord
{
    if (![self isConnecting]) {
        [self notifyForSuccess];
        return ;
    }
    self.isFromGlobal = YES;
    self.globalCoord  = coord;
    [self.workingTimer setFireDate:[NSDate distantPast]];
    [[DNPromptView sharedInstance] showLoadingView];
    [TalkingData trackEvent:kEventGlobal label:kLabelGlobalGPSWork];
}

- (void)workWithCoord:(CLLocationCoordinate2D)coord andSpeed:(int)speed
{
    if (![self isConnecting]) {
        return ;
    }
    self.isFromGlobal = NO;
    [self.workingTimer setFireDate:[NSDate distantFuture]];
    [self workWithCoord:coord speed:speed andHeading:YES];
}

- (void)workForRealCoord:(CLLocationCoordinate2D)coord
{
    if (![self isConnecting]) {
        [self notifyForSuccess];
        return ;
    }
    self.isFromGlobal = YES;
    [self.workingTimer setFireDate:[NSDate distantFuture]];
    [[DNPromptView sharedInstance] showLoadingView];
    NSString *retString = @"*#STOP#*";
    NSData *data = [retString dataUsingEncoding:NSUTF8StringEncoding];
    NSInteger ret = [self.nvcSession.outputStream write:[data bytes] maxLength:data.length];
    [TalkingData trackEvent:kEventGlobal label:kLabelGlobalGPSWork];
    [self checkResult:ret withHeading:NO andSpeed:0];
}


- (void)workWithCoord:(CLLocationCoordinate2D)coord speed:(int)speed andHeading:(BOOL)heading
{
    if (!self.receivedACK) {
        NSLog(@"~# Send GPS failed, error:no ack.");
        [self reconnectGPSDevice];
        [[NSNotificationCenter defaultCenter] postNotificationName:kGPSCMDNotification
                                                            object:nil
                                                          userInfo:@{@"pause": @(YES)}];
        return ;
    }
    
    int intLat = (int)coord.latitude;
    int intLon = (int)coord.longitude;
    CGFloat floatLat = fabs((coord.latitude - intLat)*60 + intLat*100);
    CGFloat floatLon = fabs((coord.longitude - intLon)*60 + intLon*100);
    intLat = (int)floatLat;
    intLon = (int)floatLon;
    floatLat = floatLat - intLat;
    floatLon = floatLon - intLon;
    NSString *strLat = [NSString stringWithFormat:@"%04d.%06d", intLat, (int)(floatLat*1000000)];
    NSString *strLon = [NSString stringWithFormat:@"%05d.%06d", intLon, (int)(floatLon*1000000)];
    NSString *strDate  = [self.dateFormatter stringFromDate:[NSDate date]];
    NSString *strDate2 = [self.dateFormatter2 stringFromDate:[NSDate date]];
    NSString *retString = [NSString stringWithFormat:@"*#$GPGGA,%@,%@,%@,%@,%@,$GPRMC,%@,A,%@,%@,%@,%@,%.1f,%.1f,%@,#*",
                           strDate, strLat, coord.latitude > 0 ? @"N" : @"S",
                           strLon, coord.longitude > 0 ? @"E" : @"W",
                           strDate, strLat, coord.latitude > 0 ? @"N" : @"S",
                           strLon, coord.longitude > 0 ? @"E" : @"W", [self gpsSpeed:speed],
                           heading ? [self headingFrom:self.lastCoord to:coord] : 0.0, strDate2];
    NSData *data = [retString dataUsingEncoding:NSUTF8StringEncoding];
    data = [data xor_encrypt];
    NSLog(@"\n~# Send data:%lu, hasSpace:%d.", (unsigned long)data.length, self.nvcSession.outputStream.hasSpaceAvailable);
    NSInteger ret = 0;
    if (self.nvcSession.outputStream.hasSpaceAvailable) {
        ret = [self.nvcSession.outputStream write:[data bytes] maxLength:data.length];
    }
    [self checkResult:ret withHeading:heading andSpeed:speed];
    self.lastCoord = coord;
}

- (void)checkResult:(NSInteger)ret withHeading:(BOOL)heading andSpeed:(int)speed
{
    if (ret <= 0 && speed == 0) {
        if (ret == 0) {
            NSLog(@"~# GPS has reached its capacity.");
        } else {
            NSLog(@"~# Send GPS failed, error:%@.", self.nvcSession.outputStream.streamError);
        }
        [self reconnectGPSDevice];
    } else {
        self.retryCount = 0;
        self.receivedACK = NO;
        [[DNPromptView sharedInstance] hideView:0.6];
        NSLog(@"~# Send GPS success!");
    }
}

- (void)reconnectGPSDevice
{
    if (self.nvcSession.accessory.connected && self.retryCount < 2) {
        NSLog(@"~# GPS will reconnect!<%ld>", (long)self.retryCount);
        self.receivedACK = YES;
        self.isRetryForFail = YES;
        self.retryCount ++;
        [self startConnecting];
    } else {
        self.retryCount = 0;
        [DNAlertView showAlert:kStringForGPSConnectError
                       message:nil
                    firstTitle:@"确认"
                   firstAction:nil
                   secondTitle:nil
                  secondAction:nil];
    }
}

- (void)notifyForSuccess
{
    if ([self isConnectOK]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kSendGPSDoneNotification
                                                                object:nil
                                                              userInfo:@{@"HookCoord": @(YES)}];
        });
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSendGPSDoneNotification
                                                            object:nil
                                                          userInfo:@{@"HookCoord": @(YES)}];
    }
}

#pragma mark - NSStreamDelegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventNone:
            break;
        case NSStreamEventOpenCompleted:
            break;
        case NSStreamEventHasBytesAvailable:
            // 接收到硬件数据了，根据指令定义对数据进行解析。
            [self readFromDevice];
            break;
        case NSStreamEventHasSpaceAvailable:
            // 可以发送数据给硬件了
            [self writeToDevice];
            break;
        case NSStreamEventErrorOccurred:
            break;
        case NSStreamEventEndEncountered:
            break;
        default:
            break;
    }
}

#pragma mark - Privates

- (void)startConnecting
{
    // 重连之前重置数据
    [self closeSession];
    [self registerNotification];
    NSLog(@"~# Start check connection.");
    
    // 检测是否有大牛Go硬件连接
    NSMutableString *info = [NSMutableString string];
    EAAccessoryManager *manager = [EAAccessoryManager sharedAccessoryManager];
    NSArray<EAAccessory *> *accessArr = [manager connectedAccessories];
    for (EAAccessory *access in accessArr) {
        for (NSString *proStr in access.protocolStrings) {
            [info appendFormat:@"protocolString = %@,", proStr];
            if ([proStr isEqualToString:kGPSProtocol]) {
                self.nvcAccessory = access;
                break ;
            }
        }
    }
    
    if (self.nvcAccessory) {
        [self openSession];
    } else {
        if (accessArr.count > 0 || self.isRetryForFail) {
            [[DNPromptView sharedInstance] showText:kStringForGPSConnectError andRemove:1.5];
        }
    }
}

- (void)registerNotification
{
    NSLog(@"~# Start register notification.");
    
    // 注册通知，监听硬件连接状态
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[EAAccessoryManager sharedAccessoryManager] unregisterForLocalNotifications];
    [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onGPSConnected)
                                                 name:EAAccessoryDidConnectNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onGPSDisconnected)
                                                 name:EAAccessoryDidDisconnectNotification
                                               object:nil];
}

- (void)onGPSConnected
{
    NSLog(@"~# GPS will connect.");
    [self startConnecting];
}

- (void)onGPSDisconnected
{
    NSLog(@"~# GPS has disconnected!");
    self.isConnectOK = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:kGPSDidDisconnectNotification object:nil];
}

- (void)openSession
{
    // 根据已经连接的EAAccessory对象和这个协议（反向域名字符串）来创建EASession对象，并打开输入、输出通道
    self.nvcSession = [[EASession alloc] initWithAccessory:self.nvcAccessory forProtocol:kGPSProtocol];
    if(self.nvcSession) {
        self.isConnectOK = YES;
        NSLog(@"~# GPS has connected!");
        self.nvcSession.inputStream.delegate = self;
        [self.nvcSession.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.nvcSession.inputStream open];
        
        self.nvcSession.outputStream.delegate = self;
        [self.nvcSession.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.nvcSession.outputStream open];
        
        if (self.isRetryForFail) {
            NSLog(@"~# Resend last GPS data.");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self workWithCoord:self.lastCoord];
            });
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kGPSDidConnectNotification object:nil];
    } else {
        [[DNPromptView sharedInstance] showText:kStringForGPSConnectError andRemove:1.5];
    }
    
    self.isRetryForFail = NO;
}

- (void)closeSession
{
    if (_nvcSession) {
        [[_nvcSession inputStream] close];
        [[_nvcSession inputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [[_nvcSession inputStream] setDelegate:nil];
        [[_nvcSession outputStream] close];
        [[_nvcSession outputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [[_nvcSession outputStream] setDelegate:nil];
        _nvcSession = nil;
    }
    if (_nvcAccessory) {
         _nvcAccessory = nil;
    }
    _isConnectOK = NO;
}

- (void)readFromDevice
{
    uint8_t buf[2048];
    NSInteger len = 0;
    len = [self.nvcSession.inputStream read:buf maxLength:2048];  // 读取数据
    NSString *receivedString = [NSString stringWithFormat:@"%s", buf];
    if ([receivedString isEqualToString:@"appack"]) {
        NSLog(@"~# Received data:%s.", buf);
        if (!self.receivedACK && [[DNRoutingWrapper sharedInstance] getRoutingStatus] == DNRoutingPaused) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kGPSCMDNotification
                                                                object:nil
                                                              userInfo:@{@"pause": @(NO)}];
        }
        self.receivedACK = YES;
        
        if (self.isFromGlobal) {
            [self notifyForSuccess];
        }
    }
}

- (void)writeToDevice
{
}

- (double)gpsSpeed:(int)speed
{
    if (speed > 0) {
        return speed/1.852;
    } else {
        return 0;
    }
}

- (double)headingFrom:(CLLocationCoordinate2D)fromCoord to:(CLLocationCoordinate2D)toCoord
{
    if (fromCoord.latitude == 0 && fromCoord.longitude == 0) {
        return 0.0;
    }
    
    double kRad2Deg = (180/M_PI);
    double kDeg2Rad = (M_PI/180);
    double lat1 = toCoord.latitude * kDeg2Rad;
    double lat2 = fromCoord.latitude * kDeg2Rad;
    double lon1 = toCoord.longitude;
    double lon2 = fromCoord.longitude;
    double dlon = (lon2 - lon1) * kDeg2Rad;
    
    double y = sin(dlon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dlon);
    
    double heading = atan2(y, x);
    heading = heading * kRad2Deg;
    heading = heading + 360.0;
    heading = fmod(heading, 360.0);
    heading += 180;
    if (heading > 359.9) {
        heading -= 359.9;
    }
    return heading;
}

- (void)handleGlobalWorking
{
    if ([self isConnecting]) {
        [self workWithCoord:self.globalCoord speed:0 andHeading:NO];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self.workingTimer invalidate];
}

#pragma mark - Getters

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"HHmmss.S";
    }
    return _dateFormatter;
}

- (NSDateFormatter *)dateFormatter2
{
    if (!_dateFormatter2) {
        _dateFormatter2 = [[NSDateFormatter alloc] init];
        _dateFormatter2.dateFormat = @"ddMMyy";
    }
    return _dateFormatter2;
}

- (NSTimer *)workingTimer
{
    if (!_workingTimer) {
        _workingTimer = [NSTimer timerWithTimeInterval:3
                                                target:self
                                              selector:@selector(handleGlobalWorking)
                                              userInfo:nil
                                               repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_workingTimer forMode:NSDefaultRunLoopMode];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillTerminate:)
                                                     name:@"UIApplicationWillTerminateNotification"
                                                   object:nil];
    }
    return _workingTimer;
}

@end
