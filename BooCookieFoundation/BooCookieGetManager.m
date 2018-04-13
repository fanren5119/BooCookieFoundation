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

static BooCookieGetManager *__shareManager = nil;

@interface BooCookieGetManager()

@property (nonatomic, copy) CompleteBlock completeBlok;
@property (nonatomic, strong) NSString    *safariURL;
@property (nonatomic, strong) NSString    *regexpString;
@property (nonatomic, strong) BOOSafariDomainBridge *bridge;

@end

@implementation BooCookieGetManager

+ (void)getCookieWithPlaseBoard:(NSString *)regexpString completeBlock:(CompleteBlock)completeBlock
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSString *string = [pasteboard string];
    NSString *regxStr = BOO_CookieReg;
    if (regexpString.length > 0) {
        regxStr = regexpString;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regxStr];
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


+ (void)getCookieWithSafariURL:(NSString *)safariURLStr completeBlock:(CompleteBlock)completeBlock
{
    [BooCookieGetManager shareManager].completeBlok = completeBlock;

    NSString *urlString = BOO_SAFARIURL;
    if (safariURLStr.length > 0) {
        urlString = safariURLStr;
    }
    NSURL *url = [NSURL URLWithString:urlString];
    BOOSafariDomainBridge *bridge = [BOOSafariDomainBridge safariDomainBridgeWith:url];
    [BooCookieGetManager shareManager].bridge = bridge;
    [bridge getSafariCookie];
}

+ (void)getCookieWithSafariURL:(NSString *)safariURLStr regexpString:(NSString *)regexpString completeBlock:(CompleteBlock)completeBlock
{
    CGFloat version = [[UIDevice currentDevice] systemVersion].floatValue;
    if (version >= 9.0 && version < 11.0) {
        [self getCookieWithSafariURL:safariURLStr completeBlock:completeBlock];
    } else {
        [self getCookieWithPlaseBoard:regexpString completeBlock:completeBlock];
    }
}

#pragma -mark private

+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __shareManager = [[BooCookieGetManager alloc] init];
    });
    return __shareManager;
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


+ (void)applicationOpenURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
{
    NSString *encodeUrl = url.absoluteString;
    NSDictionary *cookieDict = [self dictionaryWithURLString:encodeUrl];
    [BooCookieGetManager shareManager].completeBlok(cookieDict);
}


@end
