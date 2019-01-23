/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNRouteManager.m
 *
 * Description  : DNRouteManager
 *
 * Author       : eisen
 *
 * History      : Creation, 2018/3/28, Create the file
 *****************************************************************************************
 **/

#import "DNRouteManager.h"
#import "JLRoutes.h"
#import "DNProfileManager.h"
#import "DNBaseViewController.h"

#define kParams         @"params"
#define kPushOrPresent  @"PushOrPresent"
#define kViewController @"ViewController"

@interface DNRouteManager()

@property (nonatomic, strong) NSString *lastRouteUrl; //上一次跳转的Url
@property (nonatomic, weak) UINavigationController *rootNVC;

@end

@implementation DNRouteManager

+ (DNRouteManager *)sharedInstance
{
    static DNRouteManager *smRoutes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        smRoutes = [[DNRouteManager alloc] init];
    });
    
    return smRoutes;
}

#pragma mark - Public methods

- (void)setRootNaviViewController:(UINavigationController*)rootNVC
{
    self.rootNVC = rootNVC;
}

- (void)registerDefaultRoutes
{
    [self registerRootRoutes];
}

// 跳转 String
- (BOOL)routeURLStr:(NSString *)urlStr
{
    return [self routeURLStr:urlStr withParamsDic:nil];
}

- (BOOL)routeURLStr:(NSString *)urlStr withParamsDic:(NSDictionary *)paramsDic
{
    if (!urlStr.length) {
        return NO;
    }
    
    static NSTimeInterval lastRouteTime = 0;
    NSTimeInterval curTime = [[NSDate date] timeIntervalSince1970];
    if (fabs(curTime - lastRouteTime) < 1 && [urlStr isEqualToString:self.lastRouteUrl]) {
        return NO; //防连点: 同一个Url在1秒内不再跳转
    }
    self.lastRouteUrl = urlStr;
    lastRouteTime = [[NSDate date] timeIntervalSince1970];
    
    NSURL *routeURL = [NSURL URLWithString:urlStr];
    return [[JLRoutes globalRoutes] routeURL:routeURL withParameters:paramsDic];
}

- (void)gotoWebsite:(NSString *)url
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

#pragma mark - Privates

- (void)registerRootRoutes
{
    NSString *routePattern = [NSString stringWithFormat:@"/root/:%@/:%@", kPushOrPresent, kViewController];
    [[JLRoutes globalRoutes] addRoute:routePattern handler:^BOOL(NSDictionary<NSString *,id> *parameters) {
        if (!parameters || !parameters[kPushOrPresent] || !parameters[kViewController]) {
            return NO;
        }
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:parameters];
        NSDictionary *paramsDic = nil;
        if ([parameters valueForKey:kParams]) {
            NSData *jsonData = [[parameters valueForKey:kParams] dataUsingEncoding:NSUTF8StringEncoding];
            paramsDic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:nil];
            if (paramsDic)
            {
                [dict setObject:paramsDic forKey:kParams];
            }
        }
        
        Class class = NSClassFromString(parameters[kViewController]);
        if (class) {
            [self routeToClass:class withType:parameters[kPushOrPresent] andParams:dict];
        }
        return YES;
    }];
}

- (void)routeToClass:(Class)class withType:(NSString *)type andParams:(NSDictionary *)params
{
    if ([type isEqualToString:@"popto"]) {
        BOOL isPopOK = NO;
        for (UIViewController *tmpVC in self.rootNVC.viewControllers) {
            if ([tmpVC isKindOfClass:class]) {
                isPopOK = YES;
                [self.rootNVC popToViewController:tmpVC animated:NO];
                break;
            }
        }
        if (!isPopOK) {
            [self.rootNVC pushViewController:[[class alloc] init] animated:YES];
        }
    } else {
        DNBaseViewController *newVC = [[class alloc] init];
        if ([type isEqualToString:@"push"]) {
            [self.rootNVC pushViewController:newVC animated:YES];
        } else {
            [self.rootNVC presentViewController:newVC animated:YES completion:nil];
        }
        if ([newVC respondsToSelector:@selector(configWithParams:)]) {
            [newVC performSelector:@selector(configWithParams:) withObject:params];
        }
        
        BOOL toLogin = [[params valueForKey:@"removeToLogin"] boolValue];
        BOOL isContinue = NO;
        if (toLogin) {
            NSMutableArray *newVCArray = [NSMutableArray arrayWithArray:self.rootNVC.viewControllers];
            for (UIViewController *tmpVC in newVCArray.reverseObjectEnumerator) {
                if ([tmpVC isKindOfClass:class] && !isContinue) {
                    isContinue = YES;
                    continue;
                } else {
                    [newVCArray removeObject:tmpVC];
                    if ([tmpVC isKindOfClass:NSClassFromString(@"DNLoginViewController")] ||
                        [tmpVC isKindOfClass:NSClassFromString(@"DNRegisterViewController")]) {
                        break;
                    }
                }
            }
            self.rootNVC.viewControllers = newVCArray;
        }
        
        isContinue = NO;
        BOOL toUCenter = [[params valueForKey:@"removeToUCenter"] boolValue];
        if (toUCenter) {
            NSMutableArray *newVCArray = [NSMutableArray arrayWithArray:self.rootNVC.viewControllers];
            for (UIViewController *tmpVC in newVCArray.reverseObjectEnumerator) {
                if ([tmpVC isKindOfClass:class] && !isContinue) {
                    isContinue = YES;
                    continue;
                } else {
                    [newVCArray removeObject:tmpVC];
                    if ([tmpVC isKindOfClass:NSClassFromString(@"DNUserCenterViewController")]) {
                        break;
                    }
                }
            }
            self.rootNVC.viewControllers = newVCArray;
        }
        
        BOOL removeSelf = [[params valueForKey:@"removeSelf"] boolValue];
        if (removeSelf) {
            NSMutableArray *vcArray = [NSMutableArray arrayWithArray:self.rootNVC.viewControllers];
            if (vcArray.count >= 2) {
                UIViewController *viewController = vcArray[vcArray.count-1];
                if ([viewController isKindOfClass:class]) {
                    [vcArray removeObjectAtIndex:vcArray.count-2];
                }
            }
            self.rootNVC.viewControllers = vcArray;
        }
    }
}

@end
