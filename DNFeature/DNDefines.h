/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNDefines.h
 *
 * Description  : DNDefines
 *
 * Author       : eisen
 *
 * History      : Creation, 2018/6/29, Create the file
 *****************************************************************************************
 **/

#ifndef DNDefines_h
#define DNDefines_h

#import "UIColor+Add.h"

typedef void(^DNCallBackBlock)(id result); 

#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#pragma mark - Keys

#define kAppStoreID    @"1435681343"
#define kLCAppID       @"UAcFTRCYKsseVbkkM5AWvRJR-gzGzoHsz"
#define kLCClientKey   @"X0764VMYA1e3igHvs1l8SnXy"
#define kBaiduMapKey   @"eZyv98HFzqA994WaWsrXUpoi3PVlCftV"
#define kWChatAppID    @"wx8e75d07d8b9e2d25"
#define kMTAAppID      @"I7F6PJBMC98T"
#define kQQAppID       @"1107832940"
#define kBuglyAppID    @"2eb6d9ace1"
#define kGPSProtocol   @"com.company.accessory"
#define kChannelId     @"1"
#define kTalkingDataAppID @"78BBDD69B1DC47CD80B487157444DCBB"

#define kShowLogView   @"5678"

#pragma mark - Address

#define kCourseAddress @"http://data.daniu.net/ios/index.html" //教程地址
#define kDNGPSWebsite  @"http://www.daniu.net/daniugps.html"   //大牛GPS官网
#define kDNGPSMallUrl  @"http://mall.daniu.net/index.php?s=/home/index/info/proid/1.html" //购买链接

#pragma mark - LeanCloud

#define LCGetiOSProfile      @"getIosProfiles"        //获取iOS配置信息
#define LCGetFamilyList      @"getIosDaniuFamily"     //获取大牛家族应用列表数据

#pragma mark - NSUserDefaults

#define kReadHomeGuide         @"EverReadHomeGuide"     //是否阅读过首页的引导
#define kReadRouteGuide        @"EverReadRouteGuide"    //是否阅读过路线模拟的引导
#define kNewPointRule          @"NewPointRule"          //在所有选点的中心位置添加新点
#define kMapExtendData         @"MapExtendData"         //地图扩展功能的选择记录
#define kDaniuFamilyData       @"DaniuFamilyData"       //大牛家族的数据
#define kHookedCoord           @"HookedCoord"           //全局模拟：当前模拟的地点
#define kCoordCollection       @"CoordCollection"       //收藏夹：收藏地点
#define kHookedCoordCollection @"HookedCoordCollection" //收藏夹：历史纪录
#define kRouteLineCollection   @"CollectRouteLine"      //收藏夹：收藏路线
#define kIsAPPStoreOK          @"IsAPPStoreOK"
#define kNoMoreSelectAlert     @"NoMoreSelectAlert"     //完成选点后，不再弹出提示
#define kNoMoreRoutingAlert    @"NoMoreRoutingAlert"    //开始模拟后，不再弹出提示
#define kLocalNoticeList       @"LocalNoticeList"       //本地已经加载过的通知列表
#define kReadNoticeID          @"ReadNoticeID"          //已经读取过最新通知的ID

#pragma mark - NSNotification

#define iOSProfileDone        @"iOSProfileDone"        //iOS配置加载完成
#define kSelectRoutPath       @"SelectRoutPath"        //在收藏页面选择了某一条路线
#define SelectSearchPoint     @"SelectSearchPoint"     //选择了搜索结果列表中的某个点
#define SelectCollectionPoint @"SelectCollectionPoint" //选择了收藏夹列表中的某个点
#define RouteNavigatingInfo   @"RouteNavigatingInfo"
#define RouteNavigatingFinish @"RouteNavigatingFinish"
#define RoutingWrapperStoped  @"RoutingWrapperStoped"
#define kSelectExtendCenter   @"SelectExtendCenter"
#define kSelectMapExtend      @"SelectMapExtend"    //地图扩展功能
#define kSendGPSDoneNotification @"SendGPSDoneNotification"
#define kGPSDidConnectNotification   @"GPSDidConnectNotification"
#define kGPSDidDisconnectNotification @"GPSDidDisconnectNotification"
#define kGPSCMDNotification     @"GPSCMDNotification"

#pragma mark - Strings

#define kStringForNoNetwork       @"当前无法访问网络"
#define kStringForLocateFailed    @"获取位置信息失败，请稍后再试"
#define kStringForGPSConnectError @"连接异常，请重新插拔设备后再试！"

#pragma mark - TalkingData Events

#define kEventGlobal        @"位置模拟"
#define kEventRoute         @"路线模拟"
#define kLabelGlobalStart   @"开始"
#define kLabelGlobalStop    @"停止"
#define kLabelGlobalGPSWork @"调用硬件"
#define kLabelGlobalSuccess @"模拟成功"
#define kLabelRouteStepIn   @"进入页面"
#define kLabelRouteStart    @"开始"
#define kLabelRouteCollect  @"收藏路线"

#pragma mark - Fonts

#define DNFont18 [UIFont systemFontOfSize:18]
#define DNFont16 [UIFont systemFontOfSize:16]
#define DNFont15 [UIFont systemFontOfSize:15]
#define DNFont14 [UIFont systemFontOfSize:14]
#define DNFont12 [UIFont systemFontOfSize:12]
#define DNFont10 [UIFont systemFontOfSize:10]

#pragma mark - Colors

#define DNColorEFEFF0 [UIColor colorWithHex:0xEFEFF0] // 大牛页面的主题灰色
#define DNColor27C411 [UIColor colorWithHex:0x27C411] // 大牛按钮的主题绿色
#define DNColorF6F6F6 [UIColor colorWithHex:0xF6F6F6] // 设置页面灰色背景
#define DNColor2196F3 [UIColor colorWithHex:0x2196F3] // 路线模拟中选点的主题蓝色
#define DNColorFF549C [UIColor colorWithHex:0xFF549C] //

#define DNColor1D1D1D [UIColor colorWithHex:0x1D1D1D] // 大牛页面标题的字体颜色
#define DNColor9B9B9B [UIColor colorWithHex:0x9B9B9B] // 大牛页面副标题的字体颜色
#define DNColorD6D6D6 [UIColor colorWithHex:0xD6D6D6] // 搜索框的边框颜色

#define DNColorE53935 [UIColor colorWithHex:0xE53935] // 终点图标背景色(红色)
#define DNColorD9D9D9 [UIColor colorWithHex:0xD9D9D9] // 地图操作按钮的高亮颜色
#define DNColor5C5C5C [UIColor colorWithHex:0x5C5C5C] // Alert的背景色
#define DNColor84DD77 [UIColor colorWithHex:0x84DD77] // 设置引导GIF的圆环颜色
#define DNColorF0FFED [UIColor colorWithHex:0xF0FFED] // 大牛家族下载按钮点击后的背景色

#endif /* DNDefines_h */
