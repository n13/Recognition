//
//  UIViewController+CommonUtils.h
//
//  Created by Carlos Alcala on 5/15/15.
//  Copyright (c) 2015 ponga. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (CommonUtils)

+ (instancetype)createMain;

// return this type wrapped in a nav controller for title, buttons, etc
+ (UINavigationController *)createInNavigationController;
+ (instancetype)pa_initWithNib;

- (void)showOKAlertWithTitle:(NSString *)aTitle andMessage:(NSString *)aMessage;
- (void)showOKAlertWithTitle:(NSString *)aTitle andMessage:(NSString *)aMessage completion:(void(^)())completion;

#pragma mark Keyboard
- (void)pa_addKeyboardListeners;
- (void)pa_removeKeyboardListeners;
- (void)pa_notificationKeyboardWillShow:(NSNotification*)notification;
- (void)pa_notificationKeyboardWillHide:(NSNotification*)notification;
- (void)moveScrollViewForKeyboard:(UIScrollView*)scrollView notification:(NSNotification *)notification keyboardShowing:(BOOL)keyboardShowing;

@end
