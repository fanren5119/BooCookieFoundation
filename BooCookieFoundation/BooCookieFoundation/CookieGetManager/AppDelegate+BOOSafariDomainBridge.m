//
//  AppDelegate+BOOSafariDomainBridge.m
//  BOOSafariDomainBridge
//
//  Created by Awhisper on 16/5/11.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "AppDelegate+BOOSafariDomainBridge.h"
#import <objc/runtime.h>
#import "BOOSafariDomainBridge.h"

@implementation AppDelegate (BOOSafariDomainBridge)

+ (void)load
{
    CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 9.0) {
        Class class = [self class];
        
        SEL origSelector = @selector(application:openURL:options:);
        SEL newSelector = @selector(BOOApplication:openURL:options:);
        
        Method origMethod = class_getInstanceMethod(class,origSelector);
        
        if (!origMethod) {
            SEL emptySelector = @selector(BOOEmptyApplication:openURL:options:);
            Method emptyMethod = class_getInstanceMethod(class,emptySelector);
            IMP emptyImp = method_getImplementation(emptyMethod);
            class_addMethod(self, origSelector, emptyImp,
                            method_getTypeEncoding(emptyMethod));
        }
        
        origMethod = class_getInstanceMethod(class,origSelector);
        Method newMethod = class_getInstanceMethod(class,newSelector);
        if (origMethod && newMethod) {
            method_exchangeImplementations(origMethod, newMethod);
        }
    }
}

-(BOOL)BOOEmptyApplication:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
{
    return NO;
}

-(BOOL)BOOApplication:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options
{
    NSString *safariInfoKey = [BOOSafariDomainBridge singleton].safariKey;
    if (safariInfoKey != nil) {
        if (url) {
            NSDictionary *userInfoDic = @{@"schemeUrl":url};
            [[NSNotificationCenter defaultCenter]postNotificationName:BOOSafariInfoReceivedNotification object:self userInfo:userInfoDic];
        }
    }
    return [self BOOApplication:application openURL:url options:options];
}
@end
