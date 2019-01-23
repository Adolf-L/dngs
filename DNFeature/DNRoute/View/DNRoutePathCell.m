/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNRoutePathCell.m
 *
 * Description  : DNRoutePathCell
 *
 * Author       : eisen
 *
 * History      : Creation, 2018/6/27, Create the file
 *****************************************************************************************
 **/

#import "DNRoutePathCell.h"

@interface DNRoutePathCell()

@property (weak, nonatomic) IBOutlet UILabel *serialNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *serialLabelLeading;

@property (nonatomic, assign) BOOL isLastRow;

@property (nonatomic, strong) NSIndexPath *indexPath;

@end

@implementation DNRoutePathCell

#pragma mark - Life cycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

#pragma mark - Public

- (void)configWithData:(NSDictionary *)dataDic indexPath:(NSIndexPath *)indexPath andFold:(BOOL)fold
{
    self.indexPath = indexPath;
    NSString *serialNum = [NSString stringWithFormat:@"%ld", (long)indexPath.row+1];
    if ([dataDic valueForKey:@"index"]) {
        NSString *index = [NSString stringWithFormat:@"%@", [dataDic valueForKey:@"index"]];
        serialNum = [NSString stringWithFormat:@"%@", index];
        if ([index isEqualToString:@"起"]) {
            self.serialNumLabel.font = DNFont12;
            self.serialNumLabel.backgroundColor = DNColor27C411;
        } else if ([index isEqualToString:@"终"]) {
            self.serialNumLabel.font = DNFont12;
            self.serialNumLabel.backgroundColor = DNColorE53935;
        } else {
            self.serialNumLabel.font = DNFont15;
            self.serialNumLabel.backgroundColor = DNColor2196F3;
        }
    } else {
        self.serialNumLabel.font = DNFont15;
        self.serialNumLabel.backgroundColor = DNColor2196F3;
    }
    self.serialNumLabel.text = serialNum;
    
    NSString *address = [dataDic objectForKey:@"address"];
    if (address.length > 0) {
        self.addressLabel.text = address;
        self.addressLabel.textColor = DNColor1D1D1D;
    } else {
        self.addressLabel.textColor = DNColor9B9B9B;
    }
}

- (void)setIsLastRow:(BOOL)isLastRow
{
    _isLastRow = isLastRow;
    if (isLastRow) {
        self.serialNumLabel.textColor = DNColor2196F3;
        self.serialNumLabel.backgroundColor = [UIColor whiteColor];
        self.serialNumLabel.layer.borderWidth = 1;
        self.serialNumLabel.layer.borderColor = DNColor2196F3.CGColor;
    } else {
        self.serialNumLabel.textColor = [UIColor whiteColor];
        self.serialNumLabel.backgroundColor = DNColor2196F3;
        self.serialNumLabel.layer.borderWidth = 0;
    }
}

#pragma mark - Actions

- (IBAction)clickDeleteBtn:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(handlePathCellEvent:withIndexPath:)]) {
        [self.delegate handlePathCellEvent:DNPathCellDeleteEvent withIndexPath:self.indexPath];
    }
}

- (void)clickContentView
{
    if ([self.delegate respondsToSelector:@selector(handlePathCellEvent:withIndexPath:)]) {
        [self.delegate handlePathCellEvent:DNPathCellSelectEvent withIndexPath:self.indexPath];
    }
}

@end
