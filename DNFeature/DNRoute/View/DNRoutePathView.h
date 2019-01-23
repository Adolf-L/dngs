/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNRoutePathView.h
 *
 * Description  : DNRoutePathView
 *
 * Author       : eisen
 *
 * History      : Creation, 2018/6/27, Create the file
 *****************************************************************************************
 **/

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#define kPathCellHeight 36

@protocol DNRoutePathViewDelegate<NSObject>

- (void)onSelectPoint;

- (void)onFinishSelecting;

- (void)onEditPoints:(NSMutableArray *)keyPoints withChange:(BOOL)change;

@end

@interface DNRoutePathView : UIView

@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, assign) BOOL showFold;
@property (nonatomic, weak) id<DNRoutePathViewDelegate> delegate;

- (void)configWithPoints:(NSArray *)points;

- (void)showFoldView:(NSArray *)points;

- (void)closeFoldView;

- (void)stopEditPoints;

- (void)setStartPoint:(CLLocationCoordinate2D)startPoint;

@end
