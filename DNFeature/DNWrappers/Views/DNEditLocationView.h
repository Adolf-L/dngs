/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNEditLocationView.h
 *
 * Description  : DNEditLocationView
 *
 * Author       : eisen
 *
 * History      : Creation, 2017/2/14, Create the file
 *****************************************************************************************
 **/

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

typedef void(^DNEditLocationBlock)(CLLocationCoordinate2D coord);

@interface DNEditLocationView : UIView

@property (weak, nonatomic) IBOutlet UITextField *editLongitude;
@property (weak, nonatomic) IBOutlet UITextField *editLatitude;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editViewBottom;
@property (nonatomic, copy) DNEditLocationBlock editBlock;

@end
