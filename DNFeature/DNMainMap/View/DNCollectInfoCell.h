/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNCollectInfoCell.h
 *
 * Description  : DNCollectInfoCell
 *
 * Author       : eisen
 *
 * History      : Creation, 2017/2/22, Create the file
 *****************************************************************************************
 **/

#import <UIKit/UIKit.h>
#import <CoreLocation/CLLocation.h>

@interface DNCollectInfoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *addressDetail;
@property (weak, nonatomic) IBOutlet UILabel *addressArea;

@property (weak, nonatomic) IBOutlet UIButton *collectionBtn;

@property (nonatomic, assign) CLLocationCoordinate2D myLocation;
@property (nonatomic, strong) NSDictionary*   locationDict;

- (void)configWithInfo:(NSDictionary *)infoDic;

@end
