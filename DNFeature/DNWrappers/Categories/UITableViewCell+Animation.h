/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : UITableViewCell+Animation.h
 *
 * Description  : UITableViewCell+Animation
 *
 * Author       : eisen
 *
 * History      : Creation, 2018/1/28, Create the file
 *****************************************************************************************
 **/

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SMCellDisplayAnimationStyle) {
    SMCellDisplayAnimationTop = 0, // line by line
    SMCellDisplayAnimationLeft = 1,
    SMCellDisplayAnimationBottom = 2,
    SMCellDisplayAnimationRight = 3,
    SMCellDisplayAnimationTopTogether = 4, // together
    SMCellDisplayAnimationLeftTogether = 5,
    SMCellDisplayAnimationBottomTogether = 6,
    SMCellDisplayAnimationRightTogether = 7,
    SMCellDisplayAnimationFadeIn = 8, // fade in line by line
    SMCellDisplayAnimationFadeInTogether = 9, // fade in together
};

@interface UITableViewCell (Animation)

@property (nonatomic, assign, getter=isDisplayed) BOOL displayed;

/** 添加cell显示动画方法
 * @param tableView tableView
 * @param indexPath cell 位置
 * @param animationStyle cell 显示动画类型
 */
- (void)tableView:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath animationStyle:(SMCellDisplayAnimationStyle)animationStyle;

@end
