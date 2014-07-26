//
//  UIViewController+OPModalOverlay.m
//
//  Created by Dave Feldman on 12/5/13.
//  Copyright (c) 2013 Dave Feldman. Distributed under the MIT License (http://opensource.org/licenses/MIT)
//

#import "UIViewController+OPModalOverlay.h"

// The OS doesn't retain a reference to a UIWindow, so we need to do so here.
static UIWindow* _overlayWindow;

#define FadeBehindAlpha 0.4
#define AnimationDuration 0.25

@implementation UIViewController (OPModalOverlay)

- (void)displayInOverlaySheetWithCompletion:(void (^)(void))overlayDisplayCompletion fadeBehind:(BOOL)fadeBehind {
    if (_overlayWindow) {
        [NSException raise:@"OPModalOverlayException"
                    format:@"Attempted to display an overlay sheet when one was already visible."];
    } else {
        // TODO: Could allow for non-fullscreen sheets...
        CGRect windowFrame = [UIScreen mainScreen].applicationFrame;
        // TODO: The calculation below may not work in landscape mode, may need to use width instead.
        float statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
        windowFrame.origin.y -= statusBarHeight;
        windowFrame.size.height += statusBarHeight;
        
        // Create and configure UIWindow to hold this controller's view.
        _overlayWindow = [[UIWindow alloc] initWithFrame:windowFrame];
        
        // If we're fading the background, we assume we want the status bar faded too; otherwise, we
        // set the window level below the status bar.
        _overlayWindow.windowLevel = fadeBehind ? UIWindowLevelAlert - 1 : UIWindowLevelStatusBar - 1;
        _overlayWindow.hidden = NO;
            _overlayWindow.backgroundColor = [UIColor clearColor];
        _overlayWindow.rootViewController = self;
        
        // Shift this controller's view down so we can slide it up
        CGRect viewFrame = self.view.frame;
        viewFrame.origin.y += windowFrame.size.height;
        self.view.frame = viewFrame;
        
        viewFrame.origin.y -= windowFrame.size.height;
        [UIView animateWithDuration:AnimationDuration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
            self.view.frame = viewFrame;
            if (fadeBehind) {
                _overlayWindow.backgroundColor = [UIColor colorWithWhite:0 alpha:FadeBehindAlpha];
            }
        } completion:^(BOOL finished) {
            if (overlayDisplayCompletion) {
                overlayDisplayCompletion();
            }
        }];
    }
}

- (void)presentOverlayViewController:(UIViewController*)viewController completion:(void (^)(void))completion fadeBehind:(BOOL)fadeBehind {
    [viewController displayInOverlaySheetWithCompletion:completion fadeBehind:fadeBehind];
}

- (void)presentOverlayViewController:(UIViewController*)viewController completion:(void (^)(void))completion {
    [viewController displayInOverlaySheetWithCompletion:completion fadeBehind:NO];
}

- (void)dismissOverlay {
    if (_overlayWindow && _overlayWindow.rootViewController) {
        [UIView animateWithDuration:AnimationDuration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
            UIView* view = _overlayWindow.rootViewController.view;
            CGRect screenFrame = [UIScreen mainScreen].applicationFrame;
            CGRect viewFrame = view.frame;
            viewFrame.origin.y += screenFrame.size.height;
            view.frame = viewFrame;
            _overlayWindow.backgroundColor = [UIColor clearColor];
        } completion:^(BOOL completed){
            _overlayWindow = nil;
        }];
    }
}

@end
