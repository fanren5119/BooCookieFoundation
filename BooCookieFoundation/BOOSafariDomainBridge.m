//
//  BOOSafariDomainBridge.m
//  BOOSafariDomainBridge
//
//  Created by Awhisper on 16/5/11.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "BOOSafariDomainBridge.h"
#import <UIKit/UIKit.h>
#import <SafariServices/SafariServices.h>
#import "UIViewController+Safari.h"

@interface BOOSafariMatchView : UIView
@end
@implementation BOOSafariMatchView

- (void)setAlpha:(CGFloat)alpha
{
    [super setAlpha:0.0];
}

- (CGFloat)alpha
{
    return 1.0;
}
@end

#define BOOSafariTimeOut    30

@interface BOOSafariDomainBridge ()<SFSafariViewControllerDelegate>

@property (nonatomic, copy) BOOSafariReturn           rtblock;
@property (nonatomic, strong) SFSafariViewController  *safari;
@property (nonatomic, strong) BOOSafariMatchView      *matchView;
@property (nonatomic, strong) NSURL                   *safariUrl;

@end

@implementation BOOSafariDomainBridge

static BOOSafariDomainBridge *__BOOsingleton__;

+ (void)safariDomainBridgeWith:(NSURL *)url key:(NSString *)key
{
    if (url && key) {
        [[self singleton]setSafariUrl:url];
        [[self singleton]setSafariKey:key];
    }
}

+ (instancetype)singleton
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        __BOOsingleton__ = [[self alloc] init];
    });
    return __BOOsingleton__;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(selectorToSafariInfoRecieved:) name:BOOSafariInfoReceivedNotification object:nil];
    }
    return self;
}


- (void)getSafariCookie:(BOOSafariReturn)rtBlock
{
    if (!self.safariUrl) {
        rtBlock(NO, nil);
        return;
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
        if (rtBlock) {
            self.rtblock = rtBlock;
            [self performSelector:@selector(createSafariViewController) withObject:nil afterDelay:0];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(BOOSafariTimeOut * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self BOOTimeOut];
                [self dismissSafariViewController];
            });
        }
    } else {
        if (rtBlock) {
            rtBlock(NO,nil);
        }
    }
}

- (void)createSafariViewController
{
    SFSafariViewController *safari = [[SFSafariViewController alloc]initWithURL:self.safariUrl];
    safari.delegate = self;
    self.safari = safari;
    
    UIWindow *window = [UIViewController saf_currentWindow];
    
    safari.view.frame = window.bounds;
    
    self.matchView = [[BOOSafariMatchView alloc] initWithFrame:window.bounds];
    self.matchView.alpha = 1.0;
    self.matchView.userInteractionEnabled = NO;
    [self.matchView addSubview:safari.view];
    
    UIViewController *rootViewController = [[UIApplication sharedApplication] keyWindow].rootViewController;
    UIViewController *currentVC = [rootViewController saf_currentViewController];
    
    [currentVC addChildViewController:safari];
    UIView *parentView = currentVC.view ?: window;
    [parentView insertSubview:self.matchView atIndex:0];
    [safari didMoveToParentViewController:currentVC];
}

- (void)dismissSafariViewController
{
    [self.safari willMoveToParentViewController:nil];
    [self.safari.view removeFromSuperview];
    [self.safari removeFromParentViewController];
    self.safari.delegate = nil;
    self.safari = nil;
    
    [self.matchView removeFromSuperview];
    self.matchView = nil;
}


-(void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully
{
    [self dismissSafariViewController];
}

-(void)selectorToSafariInfoRecieved:(NSNotification *)noti
{
    NSDictionary *userInfo = noti.userInfo;
    NSURL *schemeurl = [userInfo objectForKey:@"schemeUrl"];
    NSString *encodeUrl = schemeurl.absoluteString;
    NSString *decodeUrl = [encodeUrl stringByRemovingPercentEncoding];
    if (self.rtblock) {
        self.rtblock(YES,decodeUrl);
        self.rtblock = nil;
    }
}

-(void)BOOTimeOut
{
    if (self.rtblock) {
        self.rtblock(NO,nil);
        self.rtblock = nil;
    }
}

@end
