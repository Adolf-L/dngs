/*
 *****************************************************************************************
 * Copyright (C) Beijing Deniu technology Co., Ltd. All Rights Reserved
 *
 * File         : DNEditLocationView.m
 *
 * Description  : DNEditLocationView
 *
 * Author       : eisen
 *
 * History      : Creation, 2017/2/14, Create the file
 *****************************************************************************************
 **/

#import "DNEditLocationView.h"
#import "BMKGeometry.h"

@interface DNEditLocationView()


@end

@implementation DNEditLocationView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.editLongitude becomeFirstResponder];
    self.editViewBottom.constant = 310;
    
    // 识别粘贴板中的经纬度信息
    NSString* defaultStr = [UIPasteboard generalPasteboard].string;
    NSString* retLat = nil;
    NSString* retLon = nil;
    if (defaultStr && ([defaultStr rangeOfString:@"经度"].location != NSNotFound)) {
        NSArray* stringArr = [defaultStr componentsSeparatedByString:@"，"];
        for (NSString* tmpStr in stringArr) {
            if ([tmpStr rangeOfString:@"经度"].location != NSNotFound) {
                retLon = [[tmpStr componentsSeparatedByString:@":"] lastObject];
                continue;
            }
            if ([tmpStr rangeOfString:@"纬度"].location != NSNotFound) {
                retLat = [[tmpStr componentsSeparatedByString:@":"] lastObject];
                continue;
            }
        }
    }
    if (retLat && retLon) {
        self.editLatitude.text = retLat;
        self.editLongitude.text = retLon;
    }
}

- (IBAction)actionCancle:(id)sender
{
    if (self.editBlock) {
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(0, 0);
        self.editBlock(coord);
    }
    [self.editLongitude resignFirstResponder];
    [self.editLatitude resignFirstResponder];
    [self removeFromSuperview];
}

- (IBAction)actionFinish:(id)sender
{
    if (self.editLatitude.text.length>0 && self.editLongitude.text.length>0) {
        if (self.editBlock) {
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([self.editLatitude.text floatValue],
                                                                      [self.editLongitude.text floatValue]);
            CLLocationCoordinate2D baiduCoor = BMKCoordTrans(coord, BMK_COORDTYPE_GPS, BMK_COORDTYPE_BD09LL);
            self.editBlock(baiduCoor);
        }
        [self.editLongitude resignFirstResponder];
        [self.editLatitude resignFirstResponder];
        [self removeFromSuperview];
    }
}

@end
