//
//  UIViewController+Safari.h
//
//
//  Created by Edward Smith on 11/16/17.
//  Copyright © 2017 Branch. All rights reserved.
//

#import "UIViewController+Safari.h"

@implementation UIViewController (Safari)

+ (UIWindow *)saf_currentWindow
{
    UIWindow *keyWindow = nil;
    if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)]) {
        keyWindow = [UIApplication sharedApplication].delegate.window;
    }
    if (keyWindow && !keyWindow.isHidden && keyWindow.rootViewController) return keyWindow;

    keyWindow = [UIApplication sharedApplication].keyWindow;
    if (keyWindow && !keyWindow.isHidden && keyWindow.rootViewController) return keyWindow;

    for (keyWindow in [UIApplication sharedApplication].windows.reverseObjectEnumerator) {
        if (!keyWindow.isHidden && keyWindow.rootViewController) return keyWindow;
    }
    return nil;
}

- (UIViewController *)saf_currentViewController
{
    if ([self isKindOfClass:[UINavigationController class]]) {
        return [((UINavigationController *)self).visibleViewController saf_currentViewController];
    }

    if ([self isKindOfClass:[UITabBarController class]]) {
        return [((UITabBarController *)self).selectedViewController saf_currentViewController];
    }

    if ([self isKindOfClass:[UISplitViewController class]]) {
        return [((UISplitViewController *)self).viewControllers.lastObject saf_currentViewController];
    }

    if ([self isKindOfClass:[UIPageViewController class]]) {
        return [((UIPageViewController*)self).viewControllers.lastObject saf_currentViewController];
    }

    if (self.presentedViewController != nil && !self.presentedViewController.isBeingDismissed) {
        return [self.presentedViewController saf_currentViewController];
    }

    return self;
}

@end
