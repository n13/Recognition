//
//  UIViewController+CommonUtils.m
//
//  Created by Nik Heger on 5/15/15.
//  Copyright (c) 2015 ponga. All rights reserved.
//

#import "UIViewController+CommonUtils.h"
#import "UIView+ResignFirstResponder.h"

@implementation UIViewController (CommonUtils)

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

#pragma mark Keyboard
-(void)pa_addKeyboardListeners {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pa_notificationKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pa_notificationKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
-(void)pa_removeKeyboardListeners {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
- (void)pa_notificationKeyboardWillShow:(NSNotification *)notification {
}

- (void)pa_notificationKeyboardWillHide:(NSNotification *)notification {
}

- (void)moveScrollViewForKeyboard:(UIScrollView*)scrollView notification:(NSNotification *)notification keyboardShowing:(BOOL)keyboardShowing {
    if (keyboardShowing) {
        NSDictionary *info = [notification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(scrollView.contentInset.top,0, kbSize.height+100, 0);
        scrollView.contentInset = contentInsets;
        scrollView.scrollIndicatorInsets = contentInsets;
    } else {
        scrollView.contentInset = UIEdgeInsetsMake(scrollView.contentInset.top, 0, 0, 0);
        scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(scrollView.contentInset.top, 0, 0, 0);
    }
}

- (void)pa_resignCurrentFirstResponder {
    [self.view findAndResignFirstResponder];
}


@end
