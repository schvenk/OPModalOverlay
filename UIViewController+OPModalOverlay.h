//
//  UIViewController+OPModalOverlay.h
//
//  Created by Dave Feldman on 12/5/13.
//  Copyright (c) 2013 Dave Feldman. Distributed under the MIT License (http://opensource.org/licenses/MIT)
//
//

#import <UIKit/UIKit.h>

@interface UIViewController (OPModalOverlay)

/*
 * Present an overlay sheet with the supplied view controller, on top of this
 * view controller's view.
 */
- (void)presentOverlayViewController:(UIViewController*)viewController completion:(void (^)(void))completion;

- (void)presentOverlayViewController:(UIViewController*)viewController completion:(void (^)(void))completion fadeBehind:(BOOL)fadeBehind;


/*
 * Dismiss the overlay sheet
 */
- (void)dismissOverlay;

@end
