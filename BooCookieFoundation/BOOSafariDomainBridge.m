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

@property (nonatomic, strong) SFSafariViewController  *safari;
@property (nonatomic, strong) BOOSafariMatchView      *matchView;
@property (nonatomic, strong) NSURL                   *safariUrl;

@end

@implementation BOOSafariDomainBridge

+ (instancetype)safariDomainBridgeWith:(NSURL *)url
{
    BOOSafariDomainBridge *bridge = [[BOOSafariDomainBridge alloc] init];
    bridge.safariUrl = url;
    return bridge;
}

- (void)getSafariCookie
{
    if (!self.safariUrl) {
        return;
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
        [self performSelector:@selector(createSafariViewController) withObject:nil afterDelay:0];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(BOOSafariTimeOut * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissSafariViewController];
        });
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


- (void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully
{
    [self dismissSafariViewController];
}


@end
