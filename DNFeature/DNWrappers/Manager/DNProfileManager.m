/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNProfileManager.m
 *
 * Description  : DNProfileManager
 *
 * Author       : eisen
 *
 * History      : Creation, 2018/7/10, Create the file
 *****************************************************************************************
 **/

#import "DNProfileManager.h"
#import "AVCloud.h"

@interface DNProfileManager ()

@property (nonatomic, strong) NSString *version;
@property (nonatomic, assign) BOOL isAppStoreOK;
@property (nonatomic, assign) BOOL showFamily;
@property (nonatomic, assign) BOOL hasNewFamily;

@end

@implementation DNProfileManager

#pragma mark - Life cycle

+ (DNProfileManager *)sharedInstance
{
    static DNProfileManager *appProfile = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appProfile = [[DNProfileManager alloc] init];
    });
    return appProfile;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isAppStoreOK = YES;//[[NSUserDefaults standardUserDefaults] boolForKey:kIsAPPStoreOK];
        _hasNewFamily = NO;
        _version = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
    }
    return self;
}

#pragma mark - Public

- (void)downloadiOSProfile
{
    __weak typeof(self) weakSelf = self;
    [AVCloud callFunctionInBackground:LCGetiOSProfile withParameters:nil block:^(id object, NSError *error) {
        if (error) {
            return ;
        }
        NSDictionary *profile = [NSDictionary dictionaryWithJsonString:object];
        [weakSelf handleiOSProfile:profile];
    }];
}

- (void)handleiOSProfile:(NSDictionary *)iOSProfile
{
    if (!iOSProfile) {
        return ;
    }
    
    self.version = [iOSProfile valueForKey:@"gpsversion"];
    self.showFamily = [[iOSProfile valueForKey:@"gpsShowFamily"] boolValue];
    if ([self hasNewVersion]) {
        self.isAppStoreOK = YES;
        self.hasNewFamily = [[iOSProfile valueForKey:@"hasNewFamily"] boolValue];
    } else {
        if (!self.isAppStoreOK) {
            self.isAppStoreOK = YES;//[[iOSProfile valueForKey:@"isAppStoreOK"] boolValue];
        }
    }
    NSInteger gpsNoticeID = [[iOSProfile valueForKey:@"gpsNoticeID"] integerValue];
    NSInteger readNoticeID = [[NSUserDefaults standardUserDefaults] integerForKey:kReadNoticeID];
    if (gpsNoticeID > readNoticeID) {
        self.hasNewNotice = YES;
    }
    
    if (self.isAppStoreOK) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsAPPStoreOK];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:iOSProfileDone object:nil];
}

#pragma mark - Privates

- (BOOL)hasNewVersion
{
    BOOL result = NO;
    if (!self.version) {
        return result;
    }
    
    NSString *localVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
    NSArray *localArray  = [localVersion componentsSeparatedByString:@"."];
    NSArray *latestArray = [self.version componentsSeparatedByString:@"."];
    NSInteger minArrayLength = MIN(localArray.count, latestArray.count);

    for(int i=0 ; i<minArrayLength ; i++) {
        if([localArray[i] integerValue] < [latestArray[i] integerValue]) {
            result = YES;
            break;
        }
        if ([localArray[i] integerValue] > [latestArray[i] integerValue]) {
            result = NO;
            break;
        }
    }
    return result;
}

@end
