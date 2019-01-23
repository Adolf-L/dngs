/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNShareView.m
 *
 * Description  : DNShareView
 *
 * Author       : eisen
 *
 * History      : Creation, 2017/2/23, Create the file
 *****************************************************************************************
 **/

#import "DNShareView.h"
#import "WXApi.h"
#import "QQApiInterface.h"
#import "QQApiInterfaceObject.h"
#define kShareViewHeight  180.0f
#define kShareViewBgColor 0x333333

@interface DNShareView()

@property (nonatomic, strong) UILabel  *titleLabel;
@property (nonatomic, strong) UIView   *contentView;
@property (nonatomic, strong) UIButton *cancelBtn;

@end

@implementation DNShareView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self layoutShareView];
    }
    return self;
}

#pragma mark - Actions

- (void)handleWXShare:(UIButton *)sender
{
    switch (sender.tag) {
        case 0:
            [self shareToWeChat:0 content:self.sessionContent];
            break;
        case 1:
            [self shareToWeChat:1 content:self.publicContent];
            break;
        case 2:
        {
            QQApiTextObject* textObj = [QQApiTextObject objectWithText:self.sessionContent];
            textObj.shareDestType = ShareDestTypeQQ;
            SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:textObj];
            QQApiSendResultCode sent = [QQApiInterface sendReq:req];
            [self handleSendResult:sent];
        }
            break;
        case 3:
        {
            QQApiImageArrayForQZoneObject *obj = [QQApiImageArrayForQZoneObject objectWithimageDataArray:nil title:self.publicContent extMap:nil];
            obj.shareDestType = ShareDestTypeQQ;
            SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:obj];
            QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
            [self handleSendResult:sent];
        }
            break;
            
        default:
            break;
    }
    [self showCloseAnimation];
}

#pragma mark - UIGestureRecognizerDelegate

- (void)hanldeTapEvent:(UITapGestureRecognizer *)sender
{
    CGPoint tapPoint = [sender locationInView:self];
    if (!CGRectContainsPoint(self.contentView.frame, tapPoint)) {
        [self showCloseAnimation];
    }
}

#pragma mark - Privates

- (void)layoutShareView
{
    self.backgroundColor = [UIColor colorWithHex:kShareViewBgColor alpha:0];
    UITapGestureRecognizer* tapBlank = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(hanldeTapEvent:)];
    [self addGestureRecognizer:tapBlank];
    
    // 按钮控制区域
    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.cornerRadius = 3;
    self.contentView.layer.masksToBounds = YES;
    [self addSubview:self.contentView];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = DNColor9B9B9B;
    self.titleLabel.font = DNFont15;
    self.titleLabel.text = @"分享";
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.titleLabel];
    
    // 分享按钮
    UIButton *wxSession = [self obtainButton:0 imgName:@"DNFeature.bundle/share_wechat"];
    [self.contentView addSubview:wxSession];
    UIButton *wxTimeLine = [self obtainButton:1 imgName:@"DNFeature.bundle/share_wxcircle"];
    [self.contentView addSubview:wxTimeLine];
    UIButton *qqSession = [self obtainButton:2 imgName:@"DNFeature.bundle/share_qq"];
    [self.contentView addSubview:qqSession];
    UIButton *qqZone = [self obtainButton:3 imgName:@"DNFeature.bundle/share_qqzone"];
    [self.contentView addSubview:qqZone];
    
    // 分割线
    UIView *seperateLine = [[UIView alloc] init];
    seperateLine.backgroundColor = DNColorEFEFF0;
    [self.contentView addSubview:seperateLine];
    
    // 关闭按钮
    UIButton *closeBtn = [[UIButton alloc] init];
    [closeBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [closeBtn setImage:[UIImage imageNamed:@"DNFeature.bundle/share_close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(showCloseAnimation) forControlEvents:UIControlEventTouchDown];
    [self.contentView addSubview:closeBtn];
    
    NSArray *shareBtns = @[wxSession, wxTimeLine, qqSession, qqZone];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.equalTo(self).offset(kShareViewHeight);
        make.height.mas_equalTo(@(kShareViewHeight));
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(6);
        make.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(@(30));
    }];
    [shareBtns mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:15 leadSpacing:15 tailSpacing:15];
    [shareBtns mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(10);
        make.height.mas_equalTo(@(60));
    }];
    [seperateLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wxSession.mas_bottom).offset(16);
        make.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(@(1/[UIScreen mainScreen].scale));
    }];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(seperateLine).offset(5);
        make.left.equalTo(self.contentView).offset(30);
        make.right.equalTo(self.contentView).offset(-30);
        make.bottom.equalTo(self.contentView).offset(-5);
    }];
    [self layoutIfNeeded];
}

- (void)showStartAnimation
{
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundColor = [UIColor colorWithHex:kShareViewBgColor alpha:0.4];
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(3);
        }];
        [self layoutIfNeeded];
    }];
}

- (void)showCloseAnimation
{
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundColor = [UIColor colorWithHex:kShareViewBgColor alpha:0];
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(kShareViewHeight);
        }];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (self.finishBlock) {
            self.finishBlock();
        }
        [self removeFromSuperview];
    }];
}

// 创建上图下文的按钮
- (UIButton *)obtainButton:(NSInteger)tag imgName:(NSString *)imgName
{
    UIButton *shareBtn = [[UIButton alloc] init];
    shareBtn.tag = tag;
    [shareBtn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(handleWXShare:) forControlEvents:UIControlEventTouchDown];
    [shareBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
    return shareBtn;
}

- (void)shareToWeChat:(NSInteger)scene content:(NSString *)content
{
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    if (!self.shareImage) {
        req.bText = YES;
        req.scene = (int)scene;
        req.text  = content;
    } else {
        req.bText = NO;
        req.scene = (int)scene;
        
        //创建分享内容对象
        WXMediaMessage *urlMessage = [WXMediaMessage message];
        urlMessage.title = @"大牛GPS";//分享标题
        urlMessage.description = content;//分享描述
        [urlMessage setThumbImage:self.shareImage];//分享图片,使用SDK的setThumbImage方法可压缩图片大小
        
        //创建多媒体对象
        WXWebpageObject *webObj = [WXWebpageObject object];
        webObj.webpageUrl = [NSString stringWithFormat:@"www.daniu.net"];//分享链接
        
        //完成发送对象实例
        urlMessage.mediaObject = webObj;
        req.message = urlMessage;
    }
    [WXApi sendReq:req];
}

- (void)handleSendResult:(QQApiSendResultCode)sendResult
{
    switch (sendResult)
    {
        case EQQAPIAPPNOTREGISTED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"App未注册" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送参数错误" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQQNOTINSTALLED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"未安装手Q" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPITIMNOTINSTALLED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"未安装TIM" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:
        case EQQAPITIMNOTSUPPORTAPI:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"API接口不支持" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPISENDFAILD:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIVERSIONNEEDUPDATE:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"当前QQ版本太低，需要更新" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case ETIMAPIVERSIONNEEDUPDATE:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"当前QQ版本太低，需要更新" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        default:
        {
            break;
        }
    }
}

#pragma mark - Setters

- (void)setTitle:(NSString *)title
{
    _title = title;
    _titleLabel.text = title;
}

@end
