//
//  DNExtendCenterCell.m
//  DNFeature
//
//  Created by eisen.chen on 2018/9/4.
//

#import "DNExtendCenterCell.h"

@interface DNExtendCenterCell()

@property (weak, nonatomic) IBOutlet UIImageView *leftImgView;
@property (weak, nonatomic) IBOutlet UILabel     *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *redImgView;

@property (nonatomic, strong) NSIndexPath *indexPath;

@end

@implementation DNExtendCenterCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

#pragma mark - Public

- (void)configWithData:(NSDictionary *)dataDic andIndexPath:(NSIndexPath *)indexPath
{
    NSString *leftImg = [dataDic valueForKey:@"leftImg"];
    leftImg = [NSString stringWithFormat:@"DNFeature.bundle/%@", leftImg];
    self.leftImgView.image = [UIImage imageNamed:leftImg];
    
    NSString *title = [dataDic valueForKey:@"title"];
    self.titleLabel.text = title;
    if ([title isEqualToString:@"通知"] && [DNProfileManager sharedInstance].hasNewNotice) {
        self.redImgView.hidden = NO;
    } else {
        self.redImgView.hidden = YES;
    }
}

@end
