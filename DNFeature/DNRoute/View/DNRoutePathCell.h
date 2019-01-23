/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNRoutePathCell.h
 *
 * Description  : DNRoutePathCell
 *
 * Author       : eisen
 *
 * History      : Creation, 2018/6/27, Create the file
 *****************************************************************************************
 **/

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DNPathCellEvent) {
    DNPathCellSelectEvent, // 选中事件
    DNPathCellDeleteEvent, // 删除事件
};

@protocol DNRoutePathCellDelegate<NSObject>

- (void)handlePathCellEvent:(DNPathCellEvent)event withIndexPath:(NSIndexPath *)indexPath;

@end

@interface DNRoutePathCell : UITableViewCell

@property (nonatomic, weak) id<DNRoutePathCellDelegate> delegate;

- (void)setIsLastRow:(BOOL)isLastRow;

- (void)configWithData:(NSDictionary *)dataDic indexPath:(NSIndexPath *)indexPath andFold:(BOOL)fold;

@end
