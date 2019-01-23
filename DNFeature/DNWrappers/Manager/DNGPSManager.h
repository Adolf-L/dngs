//
//  DNGPSManager.h
//  AVOSCloud
//
//  Created by eisen.chen on 2018/9/12.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface DNGPSManager : NSObject

+ (DNGPSManager *)sharedInstance;

- (void)checkConnecting;

- (BOOL)isConnecting;

- (void)workWithCoord:(CLLocationCoordinate2D)coord;

- (void)workWithCoord:(CLLocationCoordinate2D)coord andSpeed:(int)speed;

- (void)workForRealCoord:(CLLocationCoordinate2D)coord;

@end
