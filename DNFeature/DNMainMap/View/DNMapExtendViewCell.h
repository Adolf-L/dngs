//
//  DNMapExtendViewCell.h
//  AVOSCloud
//
//  Created by eisen.chen on 2018/9/10.
//

#import <UIKit/UIKit.h>

@protocol DNMapExtendViewCellDelegate <NSObject>

- (void)handleSwitchChange:(BOOL)value forIndexPath:(NSIndexPath *)indexPath;

@end

@interface DNMapExtendViewCell : UITableViewCell

@property (nonatomic, weak) id<DNMapExtendViewCellDelegate> delegate;

- (void)configWithData:(NSDictionary *)dataDic andIndexPath:(NSIndexPath *)indexPath;

@end
