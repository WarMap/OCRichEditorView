//
//  MPRichEditorToolbar.h
//  MPRichEditor
//
//  Created by warmap on 2017/7/6.
//  Copyright © 2017年 warmap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPRichEditorOptionItem.h"

@class MPRichEditorToolbar, MPRichEditorView;

typedef void (^normalBlock)();
typedef void (^toolbarBlock)(MPRichEditorToolbar *toolbar);

@protocol RichEditorToolbarDelegate

@optional

- (void)richEditorToolbarChangeTextColor:(MPRichEditorToolbar *)toolbar;
- (void)richEditorToolbarChangeBackgroundColor:(MPRichEditorToolbar *)toolbar;
- (void)richEditorToolbarInsertImage:(MPRichEditorToolbar *)toolbar;
- (void)richEditorToolbarInsertLink:(MPRichEditorToolbar *)toolbar;

@end

@interface MPRichBarButtonItem : UIBarButtonItem

@property (strong, nonatomic) normalBlock actionHandler;

- (instancetype)initWithImage:(UIImage *)image handler:(normalBlock)handler;
- (instancetype)initWithTitle:(NSString *)title handler:(normalBlock)handler;
- (void)buttonWasTapped;

@end

@interface MPRichEditorToolbar : UIView

@property (weak, nonatomic) id<RichEditorToolbarDelegate> delegate;
@property (weak, nonatomic) MPRichEditorView *editor;
@property (nonatomic, strong) NSArray<NSNumber *> *options;

@end
