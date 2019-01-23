/*
 *****************************************************************************************
 * Copyright (C) Guangzhou Shen Ma Mobile Information technology Co., Ltd. All Rights Reserved
 *
 * File			: SMMonitorLogView.m
 *
 * Description	: SMMonitorLogView
 *
 * Author		: jingzhou.cjz@alibaba-inc.com
 *
 * History		: Creation, 2017/12/6, jingzhou.cjz@alibaba-inc.com, Create the file
 *****************************************************************************************
 **/

#import "SMMonitorLogView.h"
#import "Masonry.h"
#import "fishhook.h"
#import "DNDefines.h"
#define kLogViewMinWidth  240
#define kLogViewMinHeight 200

@interface SMMonitorLogView()

@property (nonatomic, strong) UITextView  *logTextView;
@property (nonatomic, strong) UIButton    *closeBtn;
@property (nonatomic, strong) UIButton    *cleanBtn;
@property (nonatomic, strong) UIButton    *pasteBtn;
@property (nonatomic, strong) UIImageView *moveImgView;
@property (nonatomic, strong) UIImageView *zoomImgView;

@end

@implementation SMMonitorLogView

#pragma mark - fishhook

static void (*orig_NSLog)(NSString *format, ...);

void new_NSLog(NSString *format, ...)
{
    va_list args;
    va_start(args, format);
    NSString *strLog = [[NSString alloc] initWithFormat:format arguments:args];
    if ([SMMonitorLogView sharedInstance].needShowLog) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[SMMonitorLogView sharedInstance] showLog:strLog];
        });
    }
#ifdef DEBUG
    orig_NSLog(strLog);
#endif
    va_end(args);
}

#pragma mark - Life cycle

+ (SMMonitorLogView *)sharedInstance
{
    static SMMonitorLogView *sInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sInstance = [[SMMonitorLogView alloc] init];
    });
    return sInstance;
}

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(8, 30, kLogViewMinWidth, kLogViewMinHeight)];
    if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1];
        
        [self layoutSubControls];
        [self addGestureRecognizer];
        self.hidden = YES;
    }
    return self;
}

#pragma mark - Events

- (void)closeLogView
{
    self.hidden = YES;
    self.needShowLog = NO;
}

- (void)cleanLogView
{
    self.logTextView.text = nil;
}

- (void)pasteLogContent
{
    [UIPasteboard generalPasteboard].string = self.logTextView.text;
    [self showLog:@"已经复制全部log到剪贴板！"];
}

#pragma mark - GestureRecognizer

- (void)addGestureRecognizer
{
    UIPanGestureRecognizer *moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleMoveGesture:)];
    [self.moveImgView addGestureRecognizer:moveGesture];
    
    UIPanGestureRecognizer *zoomGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleZoomGesture:)];
    [self.zoomImgView addGestureRecognizer:zoomGesture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSearchCMD:)
                                                 name:SelectSearchPoint
                                               object:nil];
}

- (void)handleMoveGesture:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self];
        CGPoint newCenter = CGPointMake(self.center.x + translation.x,
                                        self.center.y + translation.y);
        if (newCenter.x - self.bounds.size.width/2 < 8) {
            newCenter.x = self.bounds.size.width/2 + 8;
        }
        if (newCenter.x + self.bounds.size.width/2 > [UIScreen mainScreen].bounds.size.width - 8) {
            newCenter.x = [UIScreen mainScreen].bounds.size.width - self.bounds.size.width/2 - 8;
        }
        if (newCenter.y - self.bounds.size.height/2 < 30) {
            newCenter.y = self.bounds.size.height/2 + 30;
        }
        if (newCenter.y + self.bounds.size.height/2 > [UIScreen mainScreen].bounds.size.height - 30) {
            newCenter.y = [UIScreen mainScreen].bounds.size.height - self.bounds.size.height/2 - 30;
        }
        self.center = newCenter;
        [recognizer setTranslation:CGPointZero inView:self];
    }
}

- (void)handleZoomGesture:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        
        CGPoint translation = [recognizer translationInView:self];
        CGRect newRect = CGRectMake(self.frame.origin.x,
                                    self.frame.origin.y,
                                    self.frame.size.width + translation.x,
                                    self.frame.size.height + translation.y);
        if (newRect.size.width < kLogViewMinWidth) {
            newRect.size.width = kLogViewMinWidth;
        }
        if (CGRectGetMaxX(newRect) > screenWidth) {
            newRect.size.width = screenWidth - newRect.origin.x;
        }
        if (newRect.size.height < kLogViewMinHeight) {
            newRect.size.height = kLogViewMinHeight;
        }
        if (CGRectGetMaxY(newRect) > screenHeight) {
            newRect.size.height = screenHeight - newRect.origin.y;
        }

        self.frame = newRect;
        [recognizer setTranslation:CGPointZero inView:self];
    }
}

- (void)handleSearchCMD:(NSNotification *)notify
{
    if ([[notify.userInfo valueForKey:@"CMD"] isEqualToString:kShowLogView]) {
        self.hidden = NO;
        self.needShowLog = YES;
    }
}

#pragma mark - Privates

- (void)layoutSubControls
{
    [self.logTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self).offset(0);
        make.bottom.equalTo(self).offset(-20);
    }];
    NSArray *tmpArray = @[self.closeBtn, self.cleanBtn, self.pasteBtn];
    [tmpArray mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(35, 20));
    }];
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.equalTo(self);
    }];
    [self.cleanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.closeBtn.mas_right).offset(3);
    }];
    [self.pasteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.cleanBtn.mas_right).offset(3);
    }];
    [self.moveImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    [self.zoomImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    [self layoutIfNeeded];
}

- (void)showLog:(NSString *)log
{
    if (![log containsString:@"~# "]) {
        return ;
    }

    NSString *oldText = self.logTextView.text;
    NSString *newText = [NSString stringWithFormat:@"%@%@\n", oldText, log];
    NSArray *array = [newText componentsSeparatedByString:@"\n"];
    if (array.count > 30) {
        NSRange range = [newText rangeOfString:@"\n"];
        newText = [newText substringFromIndex:(range.location+range.length)];
    }
    
    [self.logTextView setText:newText];
    [self.logTextView scrollRangeToVisible:NSMakeRange(0, newText.length)];
}

#pragma mark - Getters

- (UITextView *)logTextView
{
    if (!_logTextView) {
        _logTextView = [[UITextView alloc] init];
        _logTextView.editable  = NO;
        _logTextView.font = [UIFont systemFontOfSize:12];
        _logTextView.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.86];
        _logTextView.backgroundColor = [UIColor clearColor];
        [self addSubview:_logTextView];
    }
    return _logTextView;
}

- (UIButton *)closeBtn
{
    if (!_closeBtn) {
        _closeBtn = [[UIButton alloc] init];
        _closeBtn.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1];
        _closeBtn.layer.borderWidth = 1/[UIScreen mainScreen].scale;
        _closeBtn.layer.borderColor = [UIColor blueColor].CGColor;
        [_closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
        [_closeBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_closeBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [_closeBtn addTarget:self action:@selector(closeLogView) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_closeBtn];
    }
    return _closeBtn;
}

- (UIButton *)cleanBtn
{
    if (!_cleanBtn) {
        _cleanBtn = [[UIButton alloc] init];
        _cleanBtn.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1];
        _cleanBtn.layer.borderWidth = 1/[UIScreen mainScreen].scale;
        _cleanBtn.layer.borderColor = [UIColor blueColor].CGColor;
        [_cleanBtn setTitle:@"清空" forState:UIControlStateNormal];
        [_cleanBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_cleanBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [_cleanBtn addTarget:self action:@selector(cleanLogView) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cleanBtn];
    }
    return _cleanBtn;
}

- (UIButton *)pasteBtn
{
    if (!_pasteBtn) {
        _pasteBtn = [[UIButton alloc] init];
        _pasteBtn.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1];
        _pasteBtn.layer.borderWidth = 1/[UIScreen mainScreen].scale;
        _pasteBtn.layer.borderColor = [UIColor blueColor].CGColor;
        [_pasteBtn setTitle:@"复制" forState:UIControlStateNormal];
        [_pasteBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_pasteBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [_pasteBtn addTarget:self action:@selector(pasteLogContent) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_pasteBtn];
    }
    return _pasteBtn;
}

- (UIImageView *)moveImgView
{
    if (!_moveImgView) {
        _moveImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _moveImgView.userInteractionEnabled = YES;
        _moveImgView.image = [UIImage imageNamed:@"SMMonitor.bundle/monitor_log_move"];
        [self addSubview:_moveImgView];
    }
    return _moveImgView;
}

- (UIImageView *)zoomImgView
{
    if (!_zoomImgView) {
        _zoomImgView = [[UIImageView alloc] init];
        _zoomImgView.userInteractionEnabled = YES;
        _zoomImgView.image = [UIImage imageNamed:@"SMMonitor.bundle/monitor_log_zoom"];
        [self addSubview:_zoomImgView];
    }
    return _zoomImgView;
}

#pragma mark - Setters

- (void)setNeedShowLog:(BOOL)needShowLog
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rebind_symbols((struct rebinding[1]){"NSLog", new_NSLog, (void *)&orig_NSLog}, 1);
    });
    _needShowLog = needShowLog;
}

@end
