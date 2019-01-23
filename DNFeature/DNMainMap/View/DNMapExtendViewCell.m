//
//  DNMapExtendViewCell.m
//  AVOSCloud
//
//  Created by eisen.chen on 2018/9/10.
//

#import "DNMapExtendViewCell.h"

@interface DNMapExtendViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *itemImgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *moreImgView;
@property (weak, nonatomic) IBOutlet UISwitch *valueSwitch;

@property (nonatomic, strong) NSIndexPath *indexPath;

@end

@implementation DNMapExtendViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

#pragma mark - Public

- (void)configWithData:(NSDictionary *)dataDic andIndexPath:(NSIndexPath *)indexPath
{
    self.indexPath = indexPath;
    
    NSString *itemImg = [dataDic valueForKey:@"itemImg"];
    if (itemImg) {
        itemImg = [NSString stringWithFormat:@"DNFeature.bundle/%@", itemImg];
        self.itemImgView.image = [UIImage imageNamed:itemImg];
    }
    
    NSString *title = [dataDic valueForKey:@"title"];
    if (title) {
        self.titleLabel.text = title;
    }
    
    BOOL showSwitch = ([dataDic valueForKey:@"switch"] != nil);
    self.valueSwitch.hidden = !showSwitch;
    self.moreImgView.hidden = showSwitch;
    if (showSwitch) {
        [self.valueSwitch setOn:[[dataDic valueForKey:@"switch"] boolValue]];
    }
}

#pragma mark - Actions

- (IBAction)onSwitchChange:(UISwitch *)sender
{
    if ([self.delegate respondsToSelector:@selector(handleSwitchChange:forIndexPath:)]) {
        [self.delegate handleSwitchChange:sender.isOn forIndexPath:self.indexPath];
    }
}

@end
