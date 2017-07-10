//
//  UIView+RichEditor.m
//  MPRichEditor
//
//  Created by warmap on 2017/7/9.
//  Copyright © 2017年 warmap. All rights reserved.
//

#import "UIView+RichEditor.h"

@implementation UIView (RichEditor)

- (BOOL)containsFirstResponder {
    if (self.isFirstResponder) {
        return true;
    }
    for (UIView *view in self.subviews) {
        if ([view containsFirstResponder]) {
            return true;
        }
    }
    return false;
}
@end
