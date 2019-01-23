//
//  DNDrawerManager.m
//  AVOSCloud
//
//  Created by eisen.chen on 2018/9/12.
//

#import "DNDrawerManager.h"
#import "MMDrawerController.h"
#import "MMDrawerVisualState.h"
#import "DNHomeViewController.h"
#import "DNMapExtendController.h"
#import "DNExtendCenterController.h"

@interface DNDrawerManager()

@property (nonatomic, strong) MMDrawerController *rootVC;

@end

@implementation DNDrawerManager

+ (DNDrawerManager *)sharedInstance
{
    static DNDrawerManager *drawerManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        drawerManager = [[DNDrawerManager alloc] init];
    });
    return drawerManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initDrawerController];
    }
    return self;
}

- (void)initDrawerController
{
    DNHomeViewController     *homeVC  = [[DNHomeViewController alloc] init];
    DNMapExtendController    *rightVC = [[DNMapExtendController alloc] init];
    DNExtendCenterController *LeftVC  = [[DNExtendCenterController alloc] init];
    UINavigationController *homeNVC  = [[UINavigationController alloc] initWithRootViewController:homeVC];
    UINavigationController *leftNVC  = [[UINavigationController alloc] initWithRootViewController:LeftVC];
    UINavigationController *rightNVC = [[UINavigationController alloc] initWithRootViewController:rightVC];
    
    self.rootVC = [[MMDrawerController alloc] initWithCenterViewController:homeNVC
                                                                 leftDrawerViewController:leftNVC
                                                                rightDrawerViewController:rightNVC];
    self.rootVC.view.backgroundColor    = DNColorD9D9D9;
    self.rootVC.maximumLeftDrawerWidth  = 0.618*[UIScreen mainScreen].bounds.size.width;
    self.rootVC.maximumRightDrawerWidth = 0.618*[UIScreen mainScreen].bounds.size.width;
    self.rootVC.bezelPanningCenterViewRange = 15;
    [self.rootVC setShowsShadow:NO];
    [[DNRouteManager sharedInstance] setRootNaviViewController:homeNVC];
    [[DNRouteManager sharedInstance] registerDefaultRoutes];
}

- (void)closeDrawerAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    [self.rootVC closeDrawerAnimated:animated completion:completion];
}

- (void)startDrawer
{
    [self.rootVC setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeBezelPanningCenterView];
    [self.rootVC setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
}

- (void)stopDrawer
{
    [self.rootVC setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    [self.rootVC setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
}

- (void)openDrawerSide:(MMDrawerSide)drawerSide
{
    [self.rootVC toggleDrawerSide:drawerSide animated:YES completion:nil];
}

@end
