//
//  DNFamilyViewCell.m
//  DNFeature
//
//  Created by eisen.chen on 2018/9/5.
//

#import "DNFamilyViewCell.h"
#import "SDWebImageManager.h"

@interface DNFamilyViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *itemImgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;

@property (nonatomic, strong) NSString *leftUrl;

@end

@implementation DNFamilyViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.leftUrl = @"http://www.daniu.net";
    
    UIImage *bgImg = [UIImage imageFromColor:DNColorF0FFED];
    [self.downloadBtn setBackgroundImage:bgImg forState:UIControlStateHighlighted];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

#pragma mark - Public

- (void)configWithData:(NSDictionary *)dataDic andIndexPath:(NSIndexPath *)indexPath
{
    NSString *appName = [dataDic valueForKey:@"appName"];
    if (appName) {
        self.titleLabel.text = appName;
    }
    
    NSString *subTitle = [dataDic valueForKey:@"subTitle"];
    if (subTitle) {
        self.subTitleLabel.text = subTitle;
    }
    
    NSString *intro = [dataDic valueForKey:@"intro"];
    if (intro) {
        self.descriptionLabel.text = intro;
    }
    
    NSString *leftText = [dataDic valueForKey:@"leftText"];
    if (leftText) {
        [self.downloadBtn setTitle:leftText forState:UIControlStateNormal];
    }
    
    NSString *leftUrl = [dataDic valueForKey:@"leftUrl"];
    if (leftUrl) {
        self.leftUrl = leftUrl;
    }
    
    NSInteger system = [[dataDic valueForKey:@"system"] integerValue];
    NSString *downloadImg = @"DNFeature.bundle/family_download_android";
    if (system == 1) {
        downloadImg = @"DNFeature.bundle/family_download_ios";
    }
    [self.downloadBtn setImage:[UIImage imageNamed:downloadImg] forState:UIControlStateNormal];
    
    NSString *imgUrl = [dataDic valueForKey:@"imgUrl"];
    if (imgUrl) {
        if ([imgUrl containsString:@"http://"]) {
            [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:imgUrl]
                                                        options:0
                                                       progress:nil
                                                      completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                          if (image) {
                                                              self.itemImgView.image = image;
                                                          }
                                                      }];
        } else {
            imgUrl = [NSString stringWithFormat:@"DNFeature.bundle/%@", imgUrl];
            self.itemImgView.image = [UIImage imageNamed:imgUrl];
        }
    }
}

#pragma mark - Actions

- (IBAction)onDownloadAPP:(UIButton *)sender
{
    if (self.leftUrl) {
        [[DNRouteManager sharedInstance] gotoWebsite:self.leftUrl];
    }
}

@end
