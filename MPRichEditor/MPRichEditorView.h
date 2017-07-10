//
//  MPRichEditorView.h
//  MPRichEditor
//
//  Created by warmap on 2017/7/6.
//  Copyright © 2017年 warmap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CJWWebView+HackishAccessoryHiding.h"

@class MPRichEditorView;

@protocol MPRichEditorDelegate <NSObject>

/// Called when the inner height of the text being displayed changes
/// Can be used to update the UI
@optional
- (void)richEditor:(MPRichEditorView *)editor heightDidChange:(NSInteger)height;

/// Called whenever the content inside the view changes
- (void)richEditor:(MPRichEditorView *)editor contentDidChange:(NSString *)content;

/// Called when the rich editor starts editing
- (void)richEditorTookFocus:(MPRichEditorView *)editor;

/// Called when the rich editor stops editing or loses focus
- (void)richEditorLostFocus:(MPRichEditorView *)editor;

/// Called when the RichEditorView has become ready to receive input
/// More concretely, is called when the internal UIWebView loads for the first time, and contentHTML is set
- (void)richEditorDidLoad:(MPRichEditorView *)editor;

/// Called when the internal UIWebView begins loading a URL that it does not know how to respond to
/// For example, if there is an external link, and then the user taps it
- (BOOL)richEditor:(MPRichEditorView *)editor shouldInteractWith:(NSURL *)url;

/// Called when custom actions are called by callbacks in the JS
/// By default, this method is not used unless called by some custom JS that you add
- (void)richEditor:(MPRichEditorView *)editor handle:(NSString *)action;
@end



@interface MPRichEditorView : UIView

@property (nonatomic, weak) id<MPRichEditorDelegate> delegate;

@property (strong, nonatomic, readonly) UIWebView *webView;
@property (strong, nonatomic) UIView *inputAccessoryView;
@property (nonatomic, assign, getter=isScrollEnabled) BOOL scrollEnabled;
@property (nonatomic, assign, getter=isEditingEnabled) BOOL editingEnabled;
@property (nonatomic, copy, readonly) NSString *contentHTML;
@property (nonatomic, assign, readonly) NSInteger editorHeight;
@property (nonatomic, assign, readonly) NSInteger lineHeight;
@property (nonatomic, copy) NSString *html;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, copy) NSString *selectedHref;
@property (nonatomic, assign) BOOL hasRangeSelection;
@property (nonatomic, assign) BOOL hasRangeOrCaretSelection;



- (NSString *)runJS:(NSString *)js;
- (void)insertImage:(NSString *)url alt:(NSString *)alt;
@end
