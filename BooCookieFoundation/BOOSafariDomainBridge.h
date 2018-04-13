//
//  BOOSafariDomainBridge.h
//  BOOSafariDomainBridge
//
//  Created by Awhisper on 16/5/11.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BOOSafariDomainBridge : NSObject

@property (nonatomic,readonly) NSURL *safariUrl;

+ (instancetype)safariDomainBridgeWith:(NSURL *)url;

- (void)getSafariCookie;

@end
