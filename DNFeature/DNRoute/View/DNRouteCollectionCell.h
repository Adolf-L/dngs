//
//  DNRouteCollectionCell.h
//  DNFeature
//
//  Created by eisen.chen on 2018/9/5.
//

#import <UIKit/UIKit.h>

@protocol DNRouteCollectionCellDelegate<NSObject>

- (void)onRefreshCollection;

- (void)onSelectPath:(NSIndexPath *)indexPath;

- (void)onEditNameWithIndexPath:(NSIndexPath *)indexPath andFrame:(CGRect)frame;

@end

@interface DNRouteCollectionCell : UITableViewCell

@property (nonatomic, weak) id<DNRouteCollectionCellDelegate> delegate;

- (void)configWithData:(NSDictionary *)dataDic andIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)obtainCellHeight;

@end
