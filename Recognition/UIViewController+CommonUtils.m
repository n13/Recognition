//
//  UIViewController+CommonUtils.m
//
//  Created by Carlos Alcala on 5/15/15.
//  Copyright (c) 2015 ponga. All rights reserved.
//

#import "UIViewController+CommonUtils.h"

@implementation UIViewController (CommonUtils)

+ (instancetype)create {
    return [[UIStoryboard storyboardWithName:NSStringFromClass([self class]) bundle:nil] instantiateInitialViewController];
}

+ (instancetype)createWithStoryboard:(UIStoryboard*)storyboard {
    return [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
}

+ (instancetype)createMain {
    return [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
}


+ (UINavigationController *)createInNavigationController {
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return [[UINavigationController alloc] initWithRootViewController:vc];
}


+ (instancetype) pa_initWithNib {
    // chop off leading volume name - use the existing pathextension method...
    NSString *className = [NSStringFromClass([self class]) pathExtension];
    return [[self alloc] initWithNibName:className bundle:nil];
}


- (void)showOKAlertWithTitle:(NSString *)aTitle andMessage:(NSString *)aMessage {
   [self showOKAlertWithTitle:aTitle
                   andMessage:aMessage
                   completion:nil];
}

- (UIViewController*) topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

- (void)showOKAlertWithTitle:(NSString *)aTitle andMessage:(NSString *)aMessage completion:(void(^)())completion {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:aTitle
                                          message:aMessage
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:completion];
    [alertController addAction:okAction];
    [self.topMostController presentViewController:alertController animated:YES completion:nil];
}


@end
