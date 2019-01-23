//
//  DNNoticeViewCell.m
//  AVOSCloud
//
//  Created by eisen.chen on 2018/12/15.
//

#import "DNNoticeViewCell.h"

@interface DNNoticeViewCell ()

@property (weak, nonatomic) IBOutlet UILabel  *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel  *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel  *detailLabel;
@property (weak, nonatomic) IBOutlet UIButton *websiteBtn;

@property (nonatomic, strong) NSString *detailUrl;
@property (nonatomic, assign) CGFloat  cellHeight;

@end

@implementation DNNoticeViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

#pragma mark - Public methods

- (void)configWithData:(NSDictionary *)dataDic andIndexPath:(NSIndexPath *)indexPath
{
    self.cellHeight = 48;
    self.websiteBtn.hidden  = YES;
    self.detailLabel.hidden = YES;
    
    NSString *title = [dataDic valueForKey:@"title"];
    if (title.length > 0) {
        self.titleLabel.text = title;
    }
    
    NSString *time = [dataDic valueForKey:@"time"];
    if (time.length > 0) {
        self.timeLabel.text = time;
    }
    
    NSString *detail = [dataDic valueForKey:@"detail"];
    if (detail.length > 0) {
        self.detailLabel.text = detail;
    }
    
    NSString *url = [dataDic valueForKey:@"url"];
    if (url.length > 0) {
        self.detailUrl = url;
    }
}

- (void)showDetail
{
    self.websiteBtn.hidden  = NO;
    self.detailLabel.hidden = NO;
    
    CGFloat width = kScreenWidth - 32;
    NSString *text = self.detailLabel.text;
    CGRect rect = [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}
                                     context:nil];
    self.cellHeight = rect.size.height + 42 + 30;
}

- (CGFloat)obtainCellHeight
{
    return self.cellHeight;
}

#pragma mark - Events

- (IBAction)showDetail:(UIButton *)sender
{
    if (self.detailUrl.length > 0) {
        [[DNRouteManager sharedInstance] gotoWebsite:self.detailUrl];
    }
}

@end
