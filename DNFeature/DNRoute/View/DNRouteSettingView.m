/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNRouteSettingView.m
 *
 * Description  : DNRouteSettingView
 *
 * Author       : eisen
 *
 * History      : Creation, 2018/7/4, Create the file
 *****************************************************************************************
 **/

#import "DNRouteSettingView.h"

@interface DNRouteSettingView()

@property (weak, nonatomic) IBOutlet UIView   *contentView;
@property (weak, nonatomic) IBOutlet UILabel  *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel  *timeLabel;
@property (weak, nonatomic) IBOutlet UISlider *speedSlider;
@property (weak, nonatomic) IBOutlet UISlider *timeSlider;
@property (weak, nonatomic) IBOutlet UILabel  *ruleLabel;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *typeBtnArray;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *rulesBtnArray;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *policyBtnArray;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *policyViewToping;

@property (nonatomic, strong) DNRouteModel *routeModel;
@property (nonatomic, assign) BOOL needRefresh;

@end

@implementation DNRouteSettingView

#pragma mark - Life cycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.hidden = YES;
    
    UITapGestureRecognizer *tapGesture;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapBgView:)];
    [self addGestureRecognizer:tapGesture];
}

#pragma mark - Public

- (void)configWithModel:(DNRouteModel *)routeModel
{
    self.routeModel = routeModel;
    [self configSpeedWithModel:routeModel];
    
    if (routeModel.waitTime > 0) {
        self.timeSlider.value = routeModel.waitTime;
        self.timeLabel.text = [NSString stringWithFormat:@"%ds", (int)self.timeSlider.value];;
    }
    
    for (UIButton *typeBtn in self.typeBtnArray) {
        if (typeBtn.tag == routeModel.routeType) {
            typeBtn.selected = YES;
            typeBtn.backgroundColor = DNColor27C411;
            [typeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        } else {
            [typeBtn setTitleColor:DNColor27C411 forState:UIControlStateNormal];
        }
    }
    
    for (UIButton *ruleBtn in self.rulesBtnArray) {
        if (ruleBtn.tag == routeModel.routeRule) {
            ruleBtn.selected = YES;
            ruleBtn.backgroundColor = DNColor27C411;
        }
    }
    self.ruleLabel.text = [routeModel ontatinRulePrompt];
    
    for (UIButton *policyBtn in self.policyBtnArray) {
        if (policyBtn.tag == routeModel.gpsRule) {
            policyBtn.selected = YES;
            policyBtn.backgroundColor = DNColor27C411;
        }
    }
    
    CGPoint contentCenter = [self obtainCenter:YES];
    if (self.hidden == YES) {
        self.hidden = NO;
        self.needRefresh = NO;
        self.contentView.center = [self obtainCenter:NO];
        self.contentView.layer.transform = CATransform3DMakeScale(0.05, 0.05, 1);
        [self layoutIfNeeded];
        [UIView animateWithDuration:0.3 animations:^{
            self.backgroundColor = [UIColor colorWithHex:0x04040F alpha:0.4];
            self.contentView.layer.transform = CATransform3DMakeScale(1, 1, 1);
            self.contentView.center = contentCenter;
            self.contentView.frame = [self obtainFrame:YES];
            [self layoutIfNeeded];
        }];
    } else {
        self.needRefresh = YES;
        self.contentView.frame = [self obtainFrame:YES];
    }
}

- (void)stopSetting
{
    [self onFinish:nil];
}

#pragma mark - Actions

- (IBAction)onSpeedChangedBySlider:(UISlider *)sender
{
    self.speedLabel.text = [NSString stringWithFormat:@"%dkm/h", (int)sender.value];
}

- (IBAction)onTimeChangedBySlider:(UISlider *)sender
{
    self.timeLabel.text = [NSString stringWithFormat:@"%ds", (int)sender.value];
}

- (IBAction)onSpeedChangedByBtn:(UIButton *)sender
{
    int newValue = 0;
    if (sender.tag > 0) {
        newValue = self.speedSlider.value + 1;
        newValue = newValue > [self defaultMaxSpeed] ? [self defaultMaxSpeed] : newValue;
    } else {
        newValue = self.speedSlider.value - 1;
        newValue = newValue < 1 ? 1 : newValue;
    }
    self.speedSlider.value = newValue;
    self.speedLabel.text = [NSString stringWithFormat:@"%dkm/h", newValue];
}

- (IBAction)onTimeChangedByBtn:(UIButton *)sender
{
    int newValue = 0;
    if (sender.tag > 0) {
        newValue = self.timeSlider.value + 1;
        newValue = newValue > self.timeSlider.maximumValue ? self.timeSlider.maximumValue : newValue;
    } else {
        newValue = self.timeSlider.value - 1;
        newValue = newValue < self.timeSlider.minimumValue ? self.timeSlider.minimumValue : newValue;
    }
    self.timeSlider.value = newValue;
    self.timeLabel.text = [NSString stringWithFormat:@"%ds", newValue];
}

- (IBAction)onTypeChange:(UIButton *)sender
{
    for (UIButton *typeBtn in self.typeBtnArray) {
        if (typeBtn == sender) {
            typeBtn.selected = YES;
            typeBtn.backgroundColor = DNColor27C411;
            [typeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        } else {
            typeBtn.selected = NO;
            typeBtn.backgroundColor = [UIColor whiteColor];
            [typeBtn setTitleColor:DNColor27C411 forState:UIControlStateNormal];
        }
    }
    
    CGFloat policyViewToping = -45;
    CGFloat contentViewHeight = 340;
    if (sender.tag == DNRouteTypeCar) {
        policyViewToping  = 0;
        contentViewHeight = 385;
    }
    if (self.contentViewHeight.constant != contentViewHeight) {
        [UIView animateWithDuration:0.25 animations:^{
            self.policyViewToping.constant  = policyViewToping;
            self.contentViewHeight.constant = contentViewHeight;
            [self layoutIfNeeded];
        }];
    }
    
    self.needRefresh = YES;
    self.routeModel.routeType = sender.tag;
    [self configSpeedWithModel:self.routeModel];
}

- (IBAction)onRuleChange:(UIButton *)sender
{
    for (UIButton *ruleBtn in self.rulesBtnArray) {
        if (ruleBtn == sender) {
            ruleBtn.selected = YES;
            ruleBtn.backgroundColor = DNColor27C411;
        } else {
            ruleBtn.selected = NO;
            ruleBtn.backgroundColor = [UIColor whiteColor];
        }
    }
    self.needRefresh = YES;
    self.routeModel.routeRule = sender.tag;
    self.ruleLabel.text = [self.routeModel ontatinRulePrompt];
}

- (IBAction)onPolicyChange:(UIButton *)sender
{
    for (UIButton *policyBtn in self.policyBtnArray) {
        if (policyBtn == sender) {
            policyBtn.selected = YES;
            policyBtn.backgroundColor = DNColor27C411;
        } else {
            policyBtn.selected = NO;
            policyBtn.backgroundColor = [UIColor whiteColor];
        }
    }
    self.needRefresh = YES;
    self.routeModel.gpsRule = sender.tag;
}

- (IBAction)onTapBgView:(UITapGestureRecognizer *)sender
{
    CGPoint tapPoint = [sender locationInView:self];
    if (CGRectContainsPoint(self.contentView.frame, tapPoint)) {
        return;
    }
    [self onFinish:nil];
}

- (IBAction)onFinish:(UIButton *)sender
{
    NSString *key = [NSString stringWithFormat:@"%ld", (long)self.routeModel.routeType];
    NSMutableDictionary *speedList = [NSMutableDictionary dictionaryWithDictionary:self.routeModel.speedList];
    [speedList setValue:@(self.speedSlider.value) forKey:key];
    self.routeModel.speedList = speedList;
    self.routeModel.waitTime = self.timeSlider.value;
    if ([self.delegate respondsToSelector:@selector(handleSettingResult:andRefresh:)]) {
        [self.delegate handleSettingResult:self.routeModel andRefresh:self.needRefresh];
    }

    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundColor = [UIColor colorWithHex:0x04040F alpha:0];
        self.contentView.layer.transform = CATransform3DMakeScale(0.05, 0.05, 1);
        self.contentView.center = [self obtainCenter:NO];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

#pragma mark - Privates

- (void)configSpeedWithModel:(DNRouteModel *)routeModel
{
    __block CGFloat speed = 0;
    [routeModel.speedList enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        DNRouteType routeType = [key integerValue];
        if (routeType == routeModel.routeType) {
            speed = [obj intValue];
            *stop = YES;
        }
    }];
    self.speedSlider.value = speed;
    self.speedSlider.minimumValue = 1;
    self.speedSlider.maximumValue = [self defaultMaxSpeed];
    self.speedLabel.text = [NSString stringWithFormat:@"%dkm/h", (int)speed];
}

- (CGRect)obtainFrame:(BOOL)isShow
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat height = 340;
    if (DNRouteTypeCar == self.routeModel.routeType) {
        height = 385;
    }
    
    CGRect frame = CGRectMake(0, 6, 0, 0);
    if (isShow) {
        frame.origin.x = screenSize.width - 280 - 6;
        frame.size = CGSizeMake(280, height);
    } else {
        frame.origin.x = screenSize.width - 7;
        frame.size = CGSizeMake(1, 1);
    }
    return frame;
}

- (CGPoint)obtainCenter:(BOOL)isShow
{
    CGFloat height = 340;
    if (DNRouteTypeCar == self.routeModel.routeType) {
        height = 385;
    }
    
    if (isShow) {
        return CGPointMake(kScreenWidth - 140 - 6, height/2 + 6);
    } else {
        return CGPointMake(kScreenWidth - 31, 49);
    }
}

- (CGFloat)defaultSpeed
{
    if (DNRouteTypeCar == self.routeModel.routeType) {
        return 50;
    } else if (DNRouteTypeRide == self.routeModel.routeType) {
        return 20;
    } else if (DNRouteTypeWalk == self.routeModel.routeType) {
        return 15;
    } else {
        return 80;
    }
}

- (CGFloat)defaultMaxSpeed
{
    if (DNRouteTypeCar == self.routeModel.routeType) {
        return 300;
    } else if (DNRouteTypeRide == self.routeModel.routeType) {
        return 80;
    } else if (DNRouteTypeWalk == self.routeModel.routeType) {
        return 60;
    } else {
        return 500;
    }
}

#pragma mark - Getters

- (DNRouteModel *)routeModel
{
    if (!_routeModel) {
        _routeModel = [[DNRouteModel alloc] init];
    }
    return _routeModel;
}

@end
