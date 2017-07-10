//
//  MPRichEditorOptionItem.h
//  MPRichEditor
//
//  Created by warmap on 2017/7/6.
//  Copyright © 2017年 warmap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class MPRichEditorToolbar;

typedef void (^optionBlock)(MPRichEditorToolbar *);

@protocol MPRichEditorOption

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *title;
- (void)action:(MPRichEditorToolbar *)toolbar;

@end



/// RichEditorOptionItem is a concrete implementation of RichEditorOption.
/// It can be used as a configuration object for custom objects to be shown on a RichEditorToolbar.
@interface MPRichEditorOptionItem : NSObject  <MPRichEditorOption>

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) optionBlock handler;

- (instancetype)initWith:(UIImage *)image title:(NSString *)title action:(optionBlock)action;
- (void)action:(MPRichEditorToolbar *)toolbar;

@end

typedef NS_ENUM(NSUInteger, richEditorOption) {
    richEditorOptionimage = 0,
};

@interface MPREOptionHelper : NSObject

+ (instancetype)sharedInstance;
+ (UIImage *)imageForOption:(richEditorOption)option;
+ (NSString *)titleForOption:(richEditorOption)option;

@end
