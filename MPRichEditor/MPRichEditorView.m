//
//  MPRichEditorView.m
//  MPRichEditor
//
//  Created by warmap on 2017/7/6.
//  Copyright © 2017年 warmap. All rights reserved.
//

#import "MPRichEditorView.h"
#import "UIView+RichEditor.h"
#import "NSString+RichEditor.h"

@interface MPRichEditorView ()<UIWebViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic, readwrite) UIWebView *webView;
@property (nonatomic, copy, readwrite) NSString *contentHTML;
@property (nonatomic, assign, readwrite) NSInteger editorHeight;
@property (nonatomic, assign, readwrite) NSInteger lineHeight;

@property (nonatomic, assign, getter=isContentEditable) BOOL contentEditable;
@property (nonatomic, assign, getter=isEditorLoaded) BOOL editorLoaded;
@property (nonatomic, assign, getter=isEditingEnabledVar) BOOL editingEnabledVar;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, assign) NSInteger innerLineHeight;
@property (nonatomic, assign) NSInteger clientHeight;
@property (nonatomic, copy) NSString *placeholderText;
@property (nonatomic, assign) NSInteger relativeCaretYPosition;

@end

@implementation MPRichEditorView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setDefautValue];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefautValue];
        [self setup];
    }
    return self;
}

- (void)setDefautValue {
    self.scrollEnabled = YES;
    self.editorLoaded = false;
    self.editingEnabledVar = true;
    self.innerLineHeight = 28;
    self.placeholderText = @"";
    self.webView = [[UIWebView alloc] init];
}

- (void)setup {
    self.backgroundColor = [UIColor redColor];
    
    self.webView.frame = self.bounds;
    self.webView.delegate = self;
    self.webView.keyboardDisplayRequiresUserAction = false;
    self.webView.scalesPageToFit = false;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.dataDetectorTypes = UIDataDetectorTypeAll;
    self.webView.backgroundColor = [UIColor whiteColor];
    
    self.webView.scrollView.scrollEnabled = self.isScrollEnabled;
    self.webView.scrollView.bounces = false;
    self.webView.scrollView.delegate = self;
    self.webView.scrollView.clipsToBounds = true;

    self.webView.cjw_inputAccessoryView = nil;
    
    [self addSubview:self.webView];
    
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"rich_editor" ofType:@"html"];//[[NSBundle bundleForClass:[MPRichEditorView class]] pathForResource:@"rich_editor" ofType:@"html"];
    if (filePath.length > 0) {
        NSURL *url = [NSURL fileURLWithPath:filePath isDirectory:false];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    }
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewWasTapped:)];
    self.tapRecognizer.delegate = self;
    [self addGestureRecognizer:self.tapRecognizer];
}

- (void)viewWasTapped:(UITapGestureRecognizer *)tap {
    if (![self.webView containsFirstResponder]) {
        CGPoint point = [tap locationInView:self.webView];
        [self focusAt:point];
    }
}
#pragma mark -
#pragma mark - public methods
- (NSString *)runJS:(NSString *)js {
    NSString *string = [self.webView stringByEvaluatingJavaScriptFromString:js] ? : @"" ;
    return string;
}

- (void)insertImage:(NSString *)url alt:(NSString *)alt {
    [self runJS:@"RE.prepareInsert();"];
    [self runJS:[NSString stringWithFormat:@"RE.insertImage('%@', '%@');",[url escaped], [alt escaped]]];
}

- (void)focusAt:(CGPoint)point {
    [self runJS:[NSString stringWithFormat:@"RE.focusAtPoint('%@', '%@')",@(point.x), @(point.y)]];
}

#pragma mark -
#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.isScrollEnabled) {
        scrollView.bounds = self.webView.bounds;
    }
}

#pragma mark -
#pragma mark - UIWebViewDelegate
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    // Handle pre-defined editor actions
    NSString *callbackPrefix = @"re-callback://";
    if ([request.URL.absoluteString hasPrefix:callbackPrefix]) {
        
        // When we get a callback, we need to fetch the command queue to run the commands
        // It comes in as a JSON array of commands that we need to parse
        NSString *commands = [self runJS:@"RE.getCommandQueue();"];
        NSData *data = [commands dataUsingEncoding:NSUTF8StringEncoding];
        if (data) {
            
            NSArray<NSString *> *jsonCommands;
            NSError *error;
            jsonCommands = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if (error) {
                jsonCommands = @[];
                NSLog(@"RichEditorView: Failed to parse JSON Commands");
            }
            for (NSString *str in jsonCommands) {
                [self performCommand:str];
            }
        }
        return false;
    }
    
    // User is tapping on a link, so we should react accordingly
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSURL *url =  request.URL;
        if (url) {
            if ([self.delegate respondsToSelector:@selector(richEditor:shouldInteractWith:)]) {
                BOOL shouldInteract = [self.delegate richEditor:self shouldInteractWith:url];
                if (shouldInteract) {
                    return shouldInteract;
                }
            }
        }
    }
    return true;
}

#pragma mark -
#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return true;
}

#pragma mark -
#pragma mark - private methods
- (void)performCommand:(NSString *)method {
    if ([method hasPrefix:@"ready"]) {
        // If loading for the first time, we have to set the content HTML to be displayed
        if (!self.isEditorLoaded) {
            self.editorLoaded = true;
            self.html = self.contentHTML;
            self.contentEditable = self.editingEnabledVar;
            self.placeholder = self.placeholderText;
            self.lineHeight = self.innerLineHeight;
            if ([self.delegate respondsToSelector:@selector(richEditorDidLoad:)]) {
                [self.delegate richEditorDidLoad:self];
            }
        }
        [self updateHeight];
    } else if ([method hasPrefix:@"input"]) {
        [self scrollCaretToVisible];
        NSString *content = [self runJS:@"RE.getHtml()"];
        self.contentHTML = content;
        [self updateHeight];
    } else if ([method hasPrefix:@"updateHeight"]) {
        [self updateHeight];
    } else if ([method hasPrefix:@"focus"]) {
        if ([self.delegate respondsToSelector:@selector(richEditorTookFocus:)]) {
            [self.delegate richEditorTookFocus:self];
        }
    } else if ([method hasPrefix:@"blur"]) {
        if ([self.delegate respondsToSelector:@selector(richEditorLostFocus:)]) {
            [self.delegate richEditorLostFocus:self];
        }
    } else if ([method hasPrefix:@"action/"]) {
        NSString *content = [self runJS:@"RE.getHtml()"];
        self.contentHTML = content;
        
        // If there are any custom actions being called
        // We need to tell the delegate about it
        NSString *actionPrefix = @"action/";
        NSRange range = [method rangeOfString:actionPrefix];
        NSString *action = [method stringByReplacingCharactersInRange:range withString:@""];
        if ([self.delegate respondsToSelector:@selector(richEditor:handle:)]) {
            [self.delegate richEditor:self handle:action];
        }
    }
}

- (void)updateHeight {
    NSString *heightString = [self runJS:@"document.getElementById('editor').clientHeight;"];
    NSInteger height = heightString.integerValue;
    if (self.editorHeight != height) {
        self.editorHeight = height;
    }
}

- (void)scrollCaretToVisible {
    UIScrollView *scrollView = self.webView.scrollView;
    
    CGFloat contentHeight = self.clientHeight > 0 ? (CGFloat)self.clientHeight : scrollView.frame.size.height;
    scrollView.contentSize = CGSizeMake(0, contentHeight);
    
    CGFloat lineHeight = (CGFloat)self.lineHeight;
    CGFloat cursorHeight = self.lineHeight - 4;
    CGFloat visiblePosition = (CGFloat)self.relativeCaretYPosition;
    CGPoint offset;
    if (visiblePosition + cursorHeight > scrollView.bounds.size.height) {
        offset = CGPointMake(0, visiblePosition + lineHeight - scrollView.bounds.size.height + scrollView.contentOffset.y);
        [scrollView setContentOffset:offset animated:true];
    } else if (visiblePosition < 0) {
        // Visible caret position is above what is currently visible
        CGFloat amount = scrollView.contentOffset.y + visiblePosition;
        amount = amount < 0 ? 0 : amount;
        offset = CGPointMake(scrollView.contentOffset.x, amount);
        [scrollView setContentOffset:offset animated:true];
    }
}

#pragma mark -
#pragma mark - getter & setter
- (UIView *)inputAccessoryView {
    return self.webView.cjw_inputAccessoryView;
}

- (void)setInputAccessoryView:(UIView *)inputAccessoryView {
    self.webView.cjw_inputAccessoryView = inputAccessoryView;
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    _scrollEnabled = scrollEnabled;
    self.webView.scrollView.scrollEnabled = scrollEnabled;
}

- (BOOL)isEditingEnabled {
    return self.isContentEditable;
}

- (void)setEditingEnabled:(BOOL)editingEnabled {
    self.contentEditable = editingEnabled;
}

- (BOOL)isContentEditable {
    if (self.isEditorLoaded) {
        NSString *value = [self runJS:@"RE.editor.isContentEditable"];
        self.editingEnabledVar = (value.length > 0);
        return self.editingEnabledVar;
    }
    return self.editingEnabledVar;
}

- (void)setContentEditable:(BOOL)contentEditable {
    self.editingEnabledVar = contentEditable;
    if (self.isEditorLoaded) {
        NSString *value = contentEditable ? @"true" : @"false";
        [self runJS:[NSString stringWithFormat:@"RE.editor.contentEditable = %@", value]];
    }
}

- (void)setContentHTML:(NSString *)contentHTML {
    _contentHTML = contentHTML.copy;
    if ([self.delegate respondsToSelector:@selector(richEditor:contentDidChange:)]) {
        [self.delegate richEditor:self contentDidChange:contentHTML];
    }
}

- (void)setEditorHeight:(NSInteger)editorHeight {
    _editorHeight = editorHeight;
    if ([self.delegate respondsToSelector:@selector(richEditor:heightDidChange:)]) {
        [self.delegate richEditor:self heightDidChange:editorHeight];
    }
}

- (NSInteger)lineHeight {
    NSInteger lineHeight = (NSInteger)[self runJS:@"RE.getLineHeight();"];
    if (self.isEditorLoaded && lineHeight > 0) {
        return lineHeight;
    } else {
        return self.innerLineHeight;
    }
}

- (void)setLineHeight:(NSInteger)lineHeight {
    self.innerLineHeight = lineHeight;
    [self runJS:[NSString stringWithFormat:@"RE.setLineHeight('%@px')", @(self.innerLineHeight)]];
}

- (NSInteger)clientHeight {
    NSString *heightString = [self runJS:@"document.getElementById('editor').clientHeight;"];
    return heightString.integerValue;
}

- (NSString *)html {
    return [self runJS:@"RE.getHtml();"];
}

- (void)setHtml:(NSString *)html {
    self.contentHTML = html.copy;
    if (self.isEditorLoaded) {
        [self runJS:[NSString stringWithFormat:@"RE.setHtml('%@');", [html escaped]]];
    }
}

- (NSString *)text {
    return [self runJS:@"RE.getText()"];
}

- (NSString *)placeholder {
    return self.placeholderText;
}

- (void)setPlaceholder:(NSString *)placeholder {
    self.placeholderText = placeholder.copy;
    [self runJS:[NSString stringWithFormat:@"RE.setPlaceholderText('%@');", [placeholder escaped]]];
}

- (NSString *)selectedHref {
    if (!self.hasRangeSelection) {
        return nil;
    }
    NSString *href = [self runJS:@"RE.getSelectedHref();"];
    if (href.length == 0) {
        return  nil;
    } else {
        return href;
    }
}

- (BOOL)hasRangeSelection {
    return [[self runJS:@"RE.rangeSelectionExists();"] isEqualToString:@"true"] ? true : false;
}

- (BOOL)hasRangeOrCaretSelection {
    return [[self runJS:@"RE.rangeOrCaretSelectionExists();"] isEqualToString:@"true"] ? true : false;
}

- (NSInteger)relativeCaretYPosition {
    NSString *string = [self runJS:@"RE.getRelativeCaretYPosition();"];
    return string.integerValue;
}










@end
