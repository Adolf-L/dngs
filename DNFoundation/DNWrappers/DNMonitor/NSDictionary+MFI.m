//
//  NSDictionary+MFI.m
//  AVOSCloud
//
//  Created by eisen.chen on 2018/10/11.
//

#import "NSDictionary+MFI.h"
#import "DNDefines.h"
#import "DNProfileManager.h"
#import <objc/runtime.h>

@implementation NSDictionary (MFI)

//+ (void)load
//{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsAPPStoreOK]) {
//            NSDictionary *dic = [[NSBundle mainBundle] infoDictionary];
//            [dic setValue:@[@"com.company.accessory"] forKey:@"UISupportedExternalAccessoryProtocols"];
//        }
//        [self swizzleSEL:@selector(objectForKey:) withSEL:@selector(swizzled_objectForKey:)];
//    });
//}
//
//- (id)swizzled_valueForKey:(NSString *)key
//{
//    if ([key isKindOfClass:[NSString class]] &&
//        [key isEqualToString:@"UISupportedExternalAccessoryProtocols"] &&
//        [[NSUserDefaults standardUserDefaults] boolForKey:kIsAPPStoreOK]) {
//        return @[@"com.company.accessory"];
//    } else {
//        return [self swizzled_valueForKey:key];
//    }
//}
//
//- (id)swizzled_objectForKey:(id)aKey
//{
//    if ([aKey isKindOfClass:[NSString class]] &&
//        [aKey isEqualToString:@"UISupportedExternalAccessoryProtocols"] &&
//        [[NSUserDefaults standardUserDefaults] boolForKey:kIsAPPStoreOK]) {
//        return @[@"com.company.accessory"];
//    } else {
//        return [self swizzled_objectForKey:aKey];
//    }
//}
//
//+ (void)swizzleSEL:(SEL)originalSEL withSEL:(SEL)swizzledSEL
//{
//    Class class = [self class];
//    Method originalMethod = class_getInstanceMethod(class, originalSEL);
//    Method swizzledMethod = class_getInstanceMethod(class, swizzledSEL);
//    
//    BOOL didAddMethod = class_addMethod(class,
//                                        originalSEL,
//                                        method_getImplementation(swizzledMethod),
//                                        method_getTypeEncoding(swizzledMethod));
//    if (didAddMethod) {
//        class_replaceMethod(class,
//                            swizzledSEL,
//                            method_getImplementation(originalMethod),
//                            method_getTypeEncoding(originalMethod));
//    } else {
//        method_exchangeImplementations(originalMethod, swizzledMethod);
//    }
//}

@end
