/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNCollectInfoCell.m
 *
 * Description  : DNCollectInfoCell
 *
 * Author       : eisen
 *
 * History      : Creation, 2017/2/22, Create the file
 *****************************************************************************************
 **/

#import "DNCollectInfoCell.h"

@implementation DNCollectInfoCell

#pragma mark - Publics

- (void)configWithInfo:(NSDictionary *)infoDic
{
    self.locationDict = infoDic;
    
    NSString *time = [infoDic valueForKey:@"time"];
    CGFloat latitude  = [[infoDic valueForKey:@"latitude"] floatValue];
    CGFloat longitude = [[infoDic valueForKey:@"longitude"] floatValue];
    self.addressDetail.text = [infoDic valueForKey:@"name"];
    self.addressArea.text   = [NSString stringWithFormat:@"添加时间: %@", time];
    self.myLocation = CLLocationCoordinate2DMake(latitude, longitude);
    self.collectionBtn.selected = [[infoDic valueForKey:@"isCollected"] boolValue];
}

#pragma mark - Actions

- (IBAction)actionClickCollect:(UIButton *)sender
{
    sender.selected = YES;
    
    NSMutableArray* userArray = [NSMutableArray array];
    NSArray* tmpArray = [[NSUserDefaults standardUserDefaults] objectForKey:kCoordCollection];
    if (tmpArray && [tmpArray isKindOfClass:[NSArray class]] && tmpArray.count>0) {
        userArray = [[NSMutableArray alloc] initWithArray:tmpArray];
    }
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];
    NSMutableDictionary* doct = [[NSMutableDictionary alloc]init];
    BOOL isCun = NO;
    
    CLLocationCoordinate2D collectCoord = self.myLocation;
    //判断收藏夹里面是否已经存有
    for (int i = 0; i<userArray.count; i++) {
        doct = [NSMutableDictionary dictionaryWithDictionary:userArray[i]];
        int longi2 = [doct[@"longitudeNum"] doubleValue] * 1000;
        int latitude2 = [doct[@"latitudeNum"] doubleValue] * 1000;
        NSString* whichMap2 = doct[@"whichMap"];
        
        int longi = collectCoord.longitude * 1000;
        int latidu = collectCoord.latitude * 1000;
        if ((longi2 == longi)&&(latitude2 == latidu)&&([whichMap2 isEqualToString:@"baidu"]||[whichMap2 isEqualToString:@"tencent"]||!whichMap2)) {
            isCun = YES;
            [DNPromptView showToast:@"已存在，不能重复收藏"];
            break;
        }
    }
    //如果收藏夹中没有，存入收藏夹
    if (!isCun) {
        NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        NSString *  locationString=[dateformatter stringFromDate:[NSDate date]];
        [dict setValue:self.addressDetail.text forKey:@"name"];
        [dict setValue:locationString forKey:@"time"];
        [dict setValue:@"baidu" forKey:@"whichMap"];
        [dict setValue:@(collectCoord.latitude) forKey:@"latitude"];
        [dict setValue:@(collectCoord.longitude) forKey:@"longitude"];
        [dict setValue:[NSNumber numberWithDouble:collectCoord.latitude] forKey:@"latitudeNum"];
        [dict setValue:[NSNumber numberWithDouble:collectCoord.longitude] forKey:@"longitudeNum"];

        [userArray insertObject:dict atIndex:0];
        [[NSUserDefaults standardUserDefaults] setObject:userArray forKey:kCoordCollection];
        
        //修改历史纪录
        NSMutableArray* historyArray = [NSMutableArray array];
        NSArray* tmpArray = [[NSUserDefaults standardUserDefaults] objectForKey:kHookedCoordCollection];
        if (tmpArray && [tmpArray isKindOfClass:[NSArray class]] && tmpArray.count>0) {
            historyArray = [[NSMutableArray alloc] initWithArray:tmpArray];
        }
        [historyArray removeObject:self.locationDict];
        NSMutableDictionary* tmpDict = [NSMutableDictionary dictionaryWithDictionary:self.locationDict];
        [tmpDict setValue:@"1" forKey:@"isCollected"];
        [historyArray insertObject:tmpDict atIndex:0];
        [[NSUserDefaults standardUserDefaults] setObject:historyArray forKey:kHookedCoordCollection];
        
        [DNPromptView showToast:@"添加成功"];
    }
}

@end
