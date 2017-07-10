//
//  MPRichEditorToolbar.m
//  MPRichEditor
//
//  Created by warmap on 2017/7/6.
//  Copyright © 2017年 warmap. All rights reserved.
//

#import "MPRichEditorToolbar.h"
#import "MPRichEditorView.h"
#import "MPRichEditorOptionItem.h"

@implementation MPRichBarButtonItem

- (instancetype)initWithImage:(UIImage *)image handler:(normalBlock)handler {
    self = [super initWithImage:image
                          style:UIBarButtonItemStylePlain
                         target:self
                         action:@selector(buttonWasTapped)];
    if (self) {
        self.actionHandler = handler;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title handler:(normalBlock)handler {
    NSString *safeTitle = title.length > 0 ? title : @"";
    self = [super initWithTitle:safeTitle style:UIBarButtonItemStylePlain target:self action:@selector(buttonWasTapped)];
    if (self) {
        self.actionHandler = handler;
    }
    return self;
}

- (void)buttonWasTapped {
    if (self.actionHandler) {
        self.actionHandler();
    }
}

@end



@interface MPRichEditorToolbar ()

@property (strong, nonatomic) UIToolbar *toolbar;
@property (strong, nonatomic) UIScrollView *toolbarScroll;
@property (strong, nonatomic) UIToolbar *backgroundToolbar;
@property (strong, nonatomic) UIColor *barTintColor;

@end

@implementation MPRichEditorToolbar

#pragma mark -
#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.toolbarScroll = [[UIScrollView alloc] init];
    self.toolbar = [[UIToolbar alloc] init];
    self.backgroundToolbar = [[UIToolbar alloc] init];
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.backgroundColor = [UIColor clearColor];
    
    self.backgroundToolbar.frame = self.bounds;
    self.backgroundToolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.toolbar.backgroundColor = [UIColor clearColor];
    [self.toolbar setBackgroundImage:[[UIImage alloc] init] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.toolbar setShadowImage:[[UIImage alloc] init] forToolbarPosition:UIBarPositionAny];
    
    self.toolbarScroll.frame = self.bounds;
    self.toolbarScroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.toolbarScroll.showsHorizontalScrollIndicator = false;
    self.toolbarScroll.showsVerticalScrollIndicator = false;
    self.toolbarScroll.backgroundColor = [UIColor clearColor];
    [self.toolbarScroll addSubview:self.toolbar];
    
    [self addSubview:self.backgroundToolbar];
    [self addSubview:self.toolbarScroll];
    [self updateToolbar];
};

- (void)updateToolbar {
    NSMutableArray<UIBarButtonItem *> *buttons = @[].mutableCopy;
    for (NSNumber *option in self.options) {
        richEditorOption opt = option.unsignedIntegerValue;
        
        SEL selector;
        switch (opt) {
            case richEditorOptionimage:
                selector = @selector(insertImage);
                break;
                
            default:
                break;
        }
        UIImage *image = [MPREOptionHelper imageForOption:opt];
        if (image) {
            MPRichBarButtonItem *button = [[MPRichBarButtonItem alloc] initWithImage:image
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self
                                                                              action:selector];
            [buttons addObject:button];
        } else {
            MPRichBarButtonItem *button = [[MPRichBarButtonItem alloc] initWithTitle:[MPREOptionHelper titleForOption:opt]
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self
                                                                              action:selector];
            [buttons addObject:button];
        }
    }
    self.toolbar.items = buttons;
    CGFloat defaultIconWidth = 22.f;
    CGFloat barButtonItemMargin = 11.f;
    __block CGFloat width;
    [buttons enumerateObjectsUsingBlock:^(UIBarButtonItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat w = obj.customView.frame.size.width;
        if (w == 0) {
            width += defaultIconWidth + barButtonItemMargin;
        } else {
            width += obj.customView.frame.size.width + barButtonItemMargin;
        }
    }];
    if (width < self.frame.size.width) {
        CGRect frame = self.toolbar.frame;
        frame.size.width = self.frame.size.width;
        self.toolbar.frame = frame;
    } else {
        CGRect frame = self.toolbar.frame;
        frame.size.width = width;
        self.toolbar.frame = frame;
    }
    CGRect frame = self.toolbar.frame;
    frame.size.height = 44;
    self.toolbar.frame = frame;
    CGRect frame1 = self.toolbarScroll.frame;
    frame1.size.width = width;
    self.toolbarScroll.frame = frame1;
//    toolbarScroll.contentSize.width = width
}

#pragma mark -
#pragma mark - private methods
- (void)insertImage {
    [self.delegate richEditorToolbarInsertImage:self];
}

#pragma mark -
#pragma mark - getter & setter
- (void)setOptions:(NSArray<NSNumber *> *)options {
    _options = options;
    [self updateToolbar];
}

- (UIColor *)barTintColor {
    return self.backgroundToolbar.barTintColor;
}

- (void)setBarTintColor:(UIColor *)barTintColor {
    self.backgroundToolbar.barTintColor = barTintColor;
}

@end
