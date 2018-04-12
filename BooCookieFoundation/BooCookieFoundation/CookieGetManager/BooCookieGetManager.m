//
//  BooCookieGetManager.m
//  cookiessssss
//
//  Created by wanglei on 2018/4/11.
//  Copyright © 2018年 damon. All rights reserved.
//

#import "BooCookieGetManager.h"
#import "BOOSafariDomainBridge.h"
#import <UIKit/UIKit.h>

#define BOO_SAFARIURL @"http://bc.run/api/showvdid"
#define BOO_CookieReg @"^\\[👻\\]\\[.*?\\]$"

@implementation BooCookieGetManager

+ (void)getCookieFromSafari:(void (^) (NSDictionary *cookie))completeBlock
{
    CGFloat version = [[UIDevice currentDevice] systemVersion].floatValue;
    
    if (YES) {
        [self getCookieWithPasteBoard:completeBlock];
    } else if (version >= 9.0 && version < 11.0) {
        [self getCookieWithSafariViewController:completeBlock];
    }
}

+ (void)getCookieWithSafariViewController:(void (^) (NSDictionary *cookie))completeBlock
{
    NSURL *url = [NSURL URLWithString:BOO_SAFARIURL];
    [BOOSafariDomainBridge safariDomainBridgeWith:url key:@"Boo"];
    [[BOOSafariDomainBridge singleton] getSafariCookie:^(BOOL success, NSString *cookie) {
        NSDictionary *cookieDict = [self dictionaryWithURLString:cookie];
        completeBlock(cookieDict);
    }];
}

+ (void)getCookieWithPasteBoard:(void (^) (NSDictionary *cookie))completeBlock
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSString *string = [pasteboard string];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", BOO_CookieReg];
    if (![predicate evaluateWithObject:string]) {
        completeBlock(nil);
        return;
    }
    
    NSArray *array = [string componentsSeparatedByString:@"]["];
    if (array.count < 2) {
        completeBlock(nil);
        return;
    }
    NSArray *array2 = [array[1] componentsSeparatedByString:@"]"];
    if (array2.count <= 0) {
        return;
    }
    NSDictionary *dictionary = [self dictionaryWithBase64String:array2[0]];
    completeBlock(dictionary);
}


#pragma -mark conver string to dictionary

+ (NSDictionary *)dictionaryWithURLString:(NSString *)urlString
{
    NSArray *array = [urlString componentsSeparatedByString:@"?"];
    if (array.count < 2) {
        return nil;
    }
    NSDictionary *dictionary = [self dictionaryWithString:array[1] separateString:@"&"];
    return dictionary;
}

+ (NSDictionary *)dictionaryWithBase64String:(NSString *)base64String
{
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    
    NSDictionary *dictionary = [self dictionaryWithString:decodedString separateString:@";"];
    return dictionary;
}

+ (NSDictionary *)dictionaryWithString:(NSString *)string separateString:(NSString *)separate
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:4];
    NSArray *cookieArray = [string componentsSeparatedByString:separate];
    for (NSString *cookie in cookieArray) {
        NSArray *array = [cookie componentsSeparatedByString:@"="];
        if (array.count <= 0) {
            continue;
        }
        NSString *key = array[0];
        if (key.length <= 0) {
            continue;
        }
        NSString *value = array.count > 1 ? array[1] : @"";
        dictionary[key] = value;
    }
    return dictionary;
}


@end
