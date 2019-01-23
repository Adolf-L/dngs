//
//  DNNoticeViewCell.h
//  AVOSCloud
//
//  Created by eisen.chen on 2018/12/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DNNoticeViewCell : UITableViewCell

- (void)configWithData:(NSDictionary *)dataDic andIndexPath:(NSIndexPath *)indexPath;

- (void)showDetail;

- (CGFloat)obtainCellHeight;

@end

NS_ASSUME_NONNULL_END
