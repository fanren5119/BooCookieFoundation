//
//  BOOSafariDomainBridge.h
//  BOOSafariDomainBridge
//
//  Created by Awhisper on 16/5/11.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^BOOSafariReturn)(BOOL success,NSString *cookie);

static NSString * BOOSafariInfoReceivedNotification = @"BOOSafariInfoReceivedNotification";

@interface BOOSafariDomainBridge : NSObject

@property (nonatomic,readonly) NSURL *safariUrl;

@property (nonatomic,strong) NSString *safariKey;

+ (void)safariDomainBridgeWith:(NSURL *)url key:(NSString *)key;

+ (instancetype)singleton;

- (void)getSafariCookie:(BOOSafariReturn)rtBlock;

@end
