//
//  Created by nik on 1/21/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "UIView+ResignFirstResponder.h"


@implementation UIView (ResignFirstResponder)

- (BOOL)findAndResignFirstResponder
{
    if (self.isFirstResponder) {
        [self resignFirstResponder];
        return YES;
    }
    for (UIView *subView in self.subviews) {
        if ([subView findAndResignFirstResponder])
            return YES;
    }
    return NO;
}

@end