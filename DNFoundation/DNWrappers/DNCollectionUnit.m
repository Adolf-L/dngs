/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNCollectionUnit.m
 *
 * Description  : DNCollectionUnit
 *
 * Author       : eisen
 *
 * History      : Creation, 2017/10/28, Create the file
 *****************************************************************************************
 **/

#import "DNCollectionUnit.h"
#import "DNDefines.h"
#import "DNDateUnit.h"

@implementation DNCollectionUnit

#pragma mark - Public

+ (BOOL)collectCoord:(CLLocationCoordinate2D)coord withAddress:(NSString *)address
{
    return [[self class] recordCoord:coord withAddress:address andKey:kCoordCollection];
}

+ (BOOL)historyCoord:(CLLocationCoordinate2D)coord withAddress:(NSString *)address
{
    return [[self class] recordCoord:coord withAddress:address andKey:kHookedCoordCollection];
}

+ (DNCollectResult)collectRouteLine:(NSString *)bundleID
{
    DNCollectResult result = DNCollectOK;
    
    NSMutableArray *collectionArray = [NSMutableArray array];
    NSArray *tmpArray = [[NSUserDefaults standardUserDefaults] objectForKey:kRouteLineCollection];
    if ([tmpArray isKindOfClass:[NSArray class]] && tmpArray.count>0) {
        collectionArray = [[NSMutableArray alloc] initWithArray:tmpArray];
    }
    
    for (NSDictionary *infoDic in collectionArray) {
        if ([[infoDic valueForKey:@"bundleID"] isEqualToString:bundleID]) {
            result = DNCollectExist;
            break;
        }
    }
    
    if (result == DNCollectOK) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        NSString *name = [NSString stringWithFormat:@"路线%ld", (long)(collectionArray.count+1)];
        NSString *strDate = [[DNDateUnit sharedInstance] getStringDate:[NSDate date]];
        [dict setValue:name forKey:@"name"];
        [dict setValue:bundleID forKey:@"bundleID"];
        [dict setValue:strDate forKey:@"createTime"];
        
        [collectionArray insertObject:dict atIndex:0];
        [[NSUserDefaults standardUserDefaults] setObject:collectionArray forKey:kRouteLineCollection];
    }
    return result;
}

+ (BOOL)updateCollectRoute:(NSString *)bundleID withName:(NSString *)name
{
    BOOL result = NO;
    
    NSMutableArray *collectionArray = [NSMutableArray array];
    NSArray *tmpArray = [[NSUserDefaults standardUserDefaults] objectForKey:kRouteLineCollection];
    if ([tmpArray isKindOfClass:[NSArray class]] && tmpArray.count>0) {
        collectionArray = [[NSMutableArray alloc] initWithArray:tmpArray];
    }
    
    for (int i=0 ; i<collectionArray.count ; i++) {
        NSDictionary *infoDic = collectionArray[i];
        if ([[infoDic valueForKey:@"bundleID"] isEqualToString:bundleID]) {
            NSMutableDictionary *newDic = [NSMutableDictionary dictionaryWithDictionary:infoDic];
            [newDic setValue:name forKey:@"name"];
            [collectionArray replaceObjectAtIndex:i withObject:newDic];
            result = YES;
            break;
        }
    }
    if (result) {
        [[NSUserDefaults standardUserDefaults] setObject:collectionArray forKey:kRouteLineCollection];
    }
    return result;
}

+ (BOOL)deleteCollectRoute:(NSString *)bundleID
{
    BOOL result = NO;
    
    NSMutableArray *collectionArray = [NSMutableArray array];
    NSArray *tmpArray = [[NSUserDefaults standardUserDefaults] objectForKey:kRouteLineCollection];
    if ([tmpArray isKindOfClass:[NSArray class]] && tmpArray.count>0) {
        collectionArray = [[NSMutableArray alloc] initWithArray:tmpArray];
    }
    
    for (NSDictionary *infoDic in collectionArray) {
        if ([[infoDic valueForKey:@"bundleID"] isEqualToString:bundleID]) {
            [collectionArray removeObject:infoDic];
            result = YES;
            break;
        }
    }
    if (result) {
        [[NSUserDefaults standardUserDefaults] setObject:collectionArray forKey:kRouteLineCollection];
    }
    return result;
}

#pragma mark - Privates

+ (BOOL)recordCoord:(CLLocationCoordinate2D)coord withAddress:(NSString *)address andKey:(NSString *)key
{
    BOOL result = YES;
    
    NSMutableArray *collectionArray = [NSMutableArray array];
    NSArray *tmpArray = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if ([tmpArray isKindOfClass:[NSArray class]] && tmpArray.count>0) {
        collectionArray = [[NSMutableArray alloc] initWithArray:tmpArray];
    }
    
    //判断收藏夹里面是否已经存有
    for (NSDictionary *infoDic in collectionArray) {
        double longitude = [infoDic[@"longitudeNum"] doubleValue];
        double latitude  = [infoDic[@"latitudeNum"] doubleValue];
        
        if (longitude == coord.longitude && latitude == coord.latitude) {
            result = NO;
            break;
        }
    }
    
    //如果收藏夹中没有，存入收藏夹
    if (result) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        NSString *strDate = [[DNDateUnit sharedInstance] getStringDate:[NSDate date]];
        [dict setValue:address forKey:@"name"];
        [dict setValue:strDate forKey:@"time"];
        [dict setValue:@"baidu" forKey:@"whichMap"];
        [dict setValue:@(coord.latitude) forKey:@"latitude"];
        [dict setValue:@(coord.longitude) forKey:@"longitude"];
        [dict setValue:[NSNumber numberWithDouble:coord.latitude] forKey:@"latitudeNum"];
        [dict setValue:[NSNumber numberWithDouble:coord.longitude] forKey:@"longitudeNum"];
        
        [collectionArray insertObject:dict atIndex:0];
        [[NSUserDefaults standardUserDefaults] setObject:collectionArray forKey:key];
    }
    return result;
}

@end
