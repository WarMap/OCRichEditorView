//
//  NSString+RichEditor.m
//  MPRichEditor
//
//  Created by warmap on 2017/7/9.
//  Copyright © 2017年 warmap. All rights reserved.
//

#import "NSString+RichEditor.h"

@implementation NSString (RichEditor)

- (NSString *)escaped {
    //TODO ddf
    NSString *sr = [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    return sr;
}
@end
