//
//  ViewController.m
//  MPRichEditor
//
//  Created by warmap on 2017/7/6.
//  Copyright © 2017年 warmap. All rights reserved.
//

#import "ViewController.h"
#import "MPRichEditorView.h"
#import "MPRichEditorToolbar.h"

@interface ViewController ()<MPRichEditorDelegate, RichEditorToolbarDelegate>

@property (nonatomic, strong) MPRichEditorView *editorView;
@property (nonatomic, strong) UITextView *htmlTextView;
@property (nonatomic, strong) MPRichEditorToolbar *toolbar;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customLayot];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)customLayot {
    self.editorView = [[MPRichEditorView alloc] initWithFrame:CGRectMake(0, 30, 300, 300)];
    self.editorView.delegate = self;
    self.editorView.inputAccessoryView = self.toolbar;
    self.htmlTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 330, 300, 300)];
    [self.view addSubview:_editorView];
    [self.view addSubview:self.htmlTextView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - MPRichEditorDelegate
- (void)richEditor:(MPRichEditorView *)editor contentDidChange:(NSString *)content {
    if (content.length == 0) {
        self.htmlTextView.text = @"HTML Preview";
    } else {
        self.htmlTextView.text = content;
    }
}

#pragma mark -
#pragma mark - RichEditorToolbarDelegate
- (void)richEditorToolbarInsertImage:(MPRichEditorToolbar *)toolbar {
    [toolbar.editor insertImage:@"https://gravatar.com/avatar/696cf5da599733261059de06c4d1fe22" alt:@"Gravatar"];
}

#pragma mark -
#pragma mark - getter & setter
- (MPRichEditorToolbar *)toolbar {
    if (!_toolbar) {
        _toolbar = [[MPRichEditorToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
        _toolbar.options = @[@(richEditorOptionimage)];
        _toolbar.delegate = self;
        _toolbar.editor = self.editorView;
    }
    return _toolbar;
}


@end
