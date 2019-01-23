//
//  DNRouteCollectionCell.m
//  DNFeature
//
//  Created by eisen.chen on 2018/9/5.
//

#import "DNRouteCollectionCell.h"
#import "DNRoutePathCell.h"
#import "UIView+Gradient.h"

@interface DNRouteCollectionCell()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *showDetailBtn;
@property (weak, nonatomic) IBOutlet UITableView *pointsTable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *maxTitleLabelWidth;

@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, strong) NSArray *dataList;
@property (nonatomic, strong) NSArray *keyPoints;
@property (nonatomic, strong) NSIndexPath *indexPath;

@end

@implementation DNRouteCollectionCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    self.cellHeight = 105;
    self.pointsTable.delegate = self;
    self.pointsTable.dataSource = self;
    
    NSArray *colors = @[[UIColor colorWithHex:0xFFFFFF alpha:0.3],
                        [UIColor whiteColor],
                        [UIColor whiteColor],
                        [UIColor whiteColor],
                        [UIColor whiteColor],
                        [UIColor whiteColor],
                        [UIColor whiteColor],
                        [UIColor whiteColor],
                        [UIColor whiteColor]];
    [self.showDetailBtn setGradientBackgroundWithColors:colors
                                              locations:nil
                                             startPoint:CGPointMake(0, 0)
                                               endPoint:CGPointMake(1, 0)];
    
    UILongPressGestureRecognizer *gesture;
    gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(editTitle:)];
    gesture.minimumPressDuration = 0.8;
    [self addGestureRecognizer:gesture];
    
    if (kScreenWidth > 375) {
        self.maxTitleLabelWidth.constant = 204;
    } else if (kScreenWidth > 320) {
        self.maxTitleLabelWidth.constant = 165;
    }
}

#pragma mark - Public

- (void)configWithData:(NSDictionary *)dataDic andIndexPath:(NSIndexPath *)indexPath
{
    self.indexPath = indexPath;
    self.titleLabel.text = [dataDic valueForKey:@"name"];
    self.timeLabel.text  = [dataDic valueForKey:@"createTime"];
    
    NSMutableArray *keyPoints = [NSMutableArray arrayWithArray:[dataDic valueForKey:@"keyPoints"]];
    [keyPoints enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithDictionary:obj];
        NSString *index = [NSString stringWithFormat:@"%lu", (unsigned long)(idx+1)];
        if (idx == 0) {
            index = @"起";
        } else if (idx == keyPoints.count-1) {
            index = @"终";
        }
        [infoDic setValue:index forKey:@"index"];
        keyPoints[idx] = infoDic;
    }];
    self.keyPoints = keyPoints;
    self.showDetailBtn.hidden = YES;
    self.pointsTable.scrollEnabled = NO;
    self.dataList = @[self.keyPoints[0], self.keyPoints[self.keyPoints.count-1]];
    if (self.showDetailBtn.selected) {
        self.dataList = self.keyPoints;
        self.showDetailBtn.hidden = NO;
        CGFloat offset = self.dataList.count - 2;
        offset = offset > 6 ? 6.5 : offset;
        self.cellHeight = 103 + offset * 32;
        self.pointsTable.scrollEnabled = YES;
    } else if (self.keyPoints.count > 2) {
        self.cellHeight = 113;
        self.showDetailBtn.hidden = NO;
        self.dataList = @[self.keyPoints[0], @{@"blank": @(YES)}, self.keyPoints[self.keyPoints.count-1]];
    }
    
    [self.pointsTable reloadData];
}

- (CGFloat)obtainCellHeight
{
    return self.cellHeight;
}

#pragma mark - Actions

- (IBAction)showPathDetail:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(onRefreshCollection)]) {
        [self.delegate onRefreshCollection];
    }
}

- (IBAction)addPathForRoute:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(onSelectPath:)]) {
        [self.delegate onSelectPath:self.indexPath];
    }
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *pointDic = [self.dataList objectAtIndex:indexPath.row];
    if ([[pointDic valueForKey:@"blank"] boolValue]) {
        return 8;
    } else {
        return 32;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *pointDic = [self.dataList objectAtIndex:indexPath.row];
    if ([[pointDic valueForKey:@"blank"] boolValue]) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(23, 0, 6, 8)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = [UIImage imageNamed:@"DNFeature.bundle/route_path_blank"];
        [cell addSubview:imageView];
        return cell;
    } else {
        static NSString *cellIdentifier = @"DNRoutePathCellIden";
        DNRoutePathCell* pathCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (nil == pathCell) {
            UINib* nib = [UINib nibWithNibName:@"DNRoutePathCell" bundle:nil];
            pathCell = [nib instantiateWithOwner:nil options:nil].lastObject;
            [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
        }
        [pathCell configWithData:pointDic indexPath:indexPath andFold:NO];
        return pathCell;
    }
}

#pragma mark - Privates

- (void)editTitle:(UILongPressGestureRecognizer *)recognizer
{
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    CGRect rect = [self.titleLabel convertRect:self.titleLabel.bounds toView:window];
    if ([self.delegate respondsToSelector:@selector(onEditNameWithIndexPath:andFrame:)]) {
        [self.delegate onEditNameWithIndexPath:self.indexPath andFrame:rect];
    }
}

@end
