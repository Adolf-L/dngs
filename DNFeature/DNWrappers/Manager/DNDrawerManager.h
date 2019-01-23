//
//  DNDrawerManager.h
//  AVOSCloud
//
//  Created by eisen.chen on 2018/9/12.
//

#import <Foundation/Foundation.h>
#import "MMDrawerController.h"

@interface DNDrawerManager : NSObject

@property (nonatomic, strong, readonly) MMDrawerController *rootVC;

+ (DNDrawerManager *)sharedInstance;

- (void)startDrawer;

- (void)stopDrawer;

- (void)openDrawerSide:(MMDrawerSide)drawerSide;

- (void)closeDrawerAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion;

@end
