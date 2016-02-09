//
//  UIViewController+CommonUtils.h
//
//  Created by Carlos Alcala on 5/15/15.
//  Copyright (c) 2015 ponga. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (CommonUtils)

+ (instancetype)create;
+ (instancetype)createMain;

// return this type wrapped in a nav controller for title, buttons, etc
+ (UINavigationController *)createInNavigationController;

+ (instancetype)createWithStoryboard:(UIStoryboard*)storyboard;
+ (instancetype)pa_initWithNib;

- (void)showOKAlertWithTitle:(NSString *)aTitle andMessage:(NSString *)aMessage;
- (void)showOKAlertWithTitle:(NSString *)aTitle andMessage:(NSString *)aMessage completion:(void(^)())completion;

@end
