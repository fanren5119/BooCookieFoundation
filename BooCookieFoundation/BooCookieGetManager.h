//
//  BooCookieGetManager.h
//  cookiessssss
//
//  Created by wanglei on 2018/4/11.
//  Copyright © 2018年 damon. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CompleteBlock) (NSDictionary *cookie) ;

@interface BooCookieGetManager : NSObject

+ (void)getCookieWithPlaseBoard:(NSString *)regexpString completeBlock:(CompleteBlock)completeBlock;

+ (void)getCookieWithSafariURL:(NSString *)safariURLStr completeBlock:(CompleteBlock)completeBlock;

+ (void)getCookieWithSafariURL:(NSString *)safariURLStr regexpString:(NSString *)regexpString completeBlock:(CompleteBlock)completeBlock;


+ (void)applicationOpenURL:(NSURL *)url options:(NSDictionary *)options;

@end
