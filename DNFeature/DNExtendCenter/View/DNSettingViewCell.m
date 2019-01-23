//
//  DNSettingViewCell.m
//  DNFeature
//
//  Created by eisen.chen on 2018/9/6.
//

#import "DNSettingViewCell.h"

@interface DNSettingViewCell()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UIView  *bottomLine;
@property (weak, nonatomic) IBOutlet UIImageView *rightImgView;

@end

@implementation DNSettingViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

#pragma mark - Public

- (void)configWithData:(NSDictionary *)dataDic andIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = [dataDic valueForKey:@"title"];
    if (title) {
        self.titleLabel.text = title;
    }
    NSString *value = [dataDic valueForKey:@"value"];
    if (value) {
        self.valueLabel.text = value;
        self.valueLabel.hidden = NO;
        self.rightImgView.hidden = YES;
    } else {
        self.valueLabel.hidden = YES;
        self.rightImgView.hidden = NO;
    }
    
    self.bottomLine.hidden = ![[dataDic valueForKey:@"bottomLine"] boolValue];
}

@end
