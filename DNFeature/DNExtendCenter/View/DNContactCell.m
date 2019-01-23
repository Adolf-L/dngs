//
//  DNContactCell.m
//  DNFeature
//
//  Created by eisen.chen on 2018/8/28.
//

#import "DNContactCell.h"

@interface DNContactCell()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *desLabel;

@end

@implementation DNContactCell

#pragma mark - Actions

- (IBAction)onClipboard:(UIButton *)sender
{
    NSArray *array = [self.titleLabel.text componentsSeparatedByString:@": "];
    [[UIPasteboard generalPasteboard] setString:array.lastObject];
    [DNPromptView showToast:@"已复制到粘贴板"];
}

#pragma mark - Public

- (void)configWithData:(NSDictionary *)dataInfo
{
    NSString *title = [dataInfo valueForKey:@"title"];
    if (title.length > 0) {
        self.titleLabel.text = title;
    }
    
    NSString *des = [dataInfo valueForKey:@"des"];
    if (des.length > 0) {
        self.desLabel.text = des;
    }
}

@end
