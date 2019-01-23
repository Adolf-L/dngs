/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNRouteAppCell.h
 *
 * Description  : DNRouteAppCell
 *
 * Author       : eisen
 *
 * History      : Creation, 2017/2/19, Create the file
 *****************************************************************************************
 **/

#import <UIKit/UIKit.h>
#import <CoreLocation/CLLocation.h>

@protocol DNRouteAppCellDelegate <NSObject>

- (void)onSwitchChange:(BOOL)isOn withIndexPath:(NSIndexPath *)indexPath;

@end

@interface DNRouteAppCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *appIcon;
@property (weak, nonatomic) IBOutlet UILabel *appDisplayName;
@property (weak, nonatomic) IBOutlet UILabel *appHookStatus;
@property (weak, nonatomic) IBOutlet UISwitch *appSwitch;

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) NSString * bundleID;
@property (nonatomic, strong) NSString * addressDes;
@property (nonatomic, assign) CLLocationCoordinate2D myLocation;
@property (nonatomic, weak) id<DNRouteAppCellDelegate> delegate;

@end
