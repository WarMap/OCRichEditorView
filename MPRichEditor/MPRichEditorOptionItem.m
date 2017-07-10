//
//  MPRichEditorOptionItem.m
//  MPRichEditor
//
//  Created by warmap on 2017/7/6.
//  Copyright © 2017年 warmap. All rights reserved.
//

#import "MPRichEditorOptionItem.h"

@implementation MPRichEditorOptionItem

- (instancetype)initWith:(UIImage *)image title:(NSString *)title action:(optionBlock)action {
    self = [super init];
    if (self) {
        self.image = image;
        self.title = title;
        self.handler = action;
    }
    return self;
}

- (void)action:(MPRichEditorToolbar *)toolbar {
    if (self.handler) {
        self.handler(toolbar);
    }
}

@end


@implementation MPREOptionHelper

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (UIImage *)imageForOption:(richEditorOption)option {
    switch (option) {
        case richEditorOptionimage:
            return [UIImage imageNamed:@"insert_image"];
            break;
            
        default:
            break;
    }
}

+ (NSString *)titleForOption:(richEditorOption)option {
    switch (option) {
        case richEditorOptionimage:
            return @"插入图片";
            break;
            
        default:
            break;
    }
}
@end
