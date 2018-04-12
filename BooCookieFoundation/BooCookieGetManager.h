//
//  BooCookieGetManager.h
//  cookiessssss
//
//  Created by wanglei on 2018/4/11.
//  Copyright © 2018年 damon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BooCookieGetManager : NSObject

+ (void)getCookie:(void (^) (NSDictionary *cookie))completeBlock;

+ (void)getCookieWithPlaseBoard:(BOOL)isPlasteBoard completeBlock:(void (^) (NSDictionary *cookie))completeBlock;

@end
