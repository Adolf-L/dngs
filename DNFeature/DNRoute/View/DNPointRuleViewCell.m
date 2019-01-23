//
//  DNPointRuleViewCell.m
//  DNFeature
//
//  Created by eisen.chen on 2018/9/7.
//

#import "DNPointRuleViewCell.h"

@interface DNPointRuleViewCell ()

@property (weak, nonatomic) IBOutlet UILabel     *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImgView;

@end

@implementation DNPointRuleViewCell

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
    
    self.selectedImgView.hidden = ![[dataDic valueForKey:@"selected"] boolValue];
}

@end
