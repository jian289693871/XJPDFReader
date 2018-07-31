//
//  PDFDemoViewController.m
//  XJPDFReader Example iOS
//
//  Created by xuejian on 2018/7/6.
//  Copyright © 2018年 xuejian. All rights reserved.
//

#import "PDFDemoViewController.h"
#import "XJPDFReader/XJPDFReader.h"

@interface PDFDemoViewController () <XJPDFThumbsPagebarDelegate, XJPDFReaderDelegate>
@property (nonatomic, strong) UILabel *pageTipsLabel;
@property (nonatomic, strong) XJPDFReaderContentViewController *readerVC;
@property (nonatomic, strong) XJPDFThumbsPagebar *pageBar;
//@property (nonatomic, strong) PDFThumbsToolView *toolView;
@end

@implementation PDFDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithTitle:@"缩略图" style:UIBarButtonItemStylePlain target:self action:@selector(thumbClick:)], [[UIBarButtonItem alloc] initWithTitle:@"切换方向" style:UIBarButtonItemStylePlain target:self action:@selector(direction:)]];
    
    NSError *error = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:self.pdfName ofType:@".pdf"];
    XJPDFDocument *document = [[XJPDFDocument alloc] initWithFilePath:filePath password:@"123456" error:&error];
    NSLog(@"error---->: %@", error);
    
    XJPDFReaderContentViewController *vc = [[XJPDFReaderContentViewController alloc] initWithDocument:document direction:XJReaderScrollerDirectionHorizontal];
    vc.delegate = self;
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    [vc didMoveToParentViewController:self];
    vc.view.frame = self.view.bounds;
    self.readerVC = vc;
    
    [self.view addSubview:self.pageTipsLabel];
    
    _pageBar = [[XJPDFThumbsPagebar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 80, UIScreen.mainScreen.bounds.size.width, 50) document:document];
    _pageBar.delegate = self;
    [self.view addSubview:_pageBar];
}

- (IBAction)thumbClick:(UIBarButtonItem *)sender {
    XJPDFThumbReaderViewController *vc = [[XJPDFThumbReaderViewController alloc] initWitPDFDocument:self.readerVC.pdfDocument selectedPage:0];
    vc.view.backgroundColor = [UIColor grayColor];
    [self.navigationController pushViewController:vc animated:YES];
    __weak typeof(self) weakSelf = self;
    vc.thumbReaderPageDidSelected = ^(XJPDFThumbReaderViewController *vc, NSInteger selectPage) {
        [weakSelf.readerVC goDocumentAtPage:selectPage animated:YES];
        [vc.navigationController popViewControllerAnimated:NO];
    };
}

- (void)direction:(UIBarButtonItem *)sender {
    if (self.readerVC.direction == XJReaderScrollerDirectionHorizontal) {
        [self.readerVC changeReaderScrollerDirection:XJReaderScrollerDirectionVertical];
    } else {
        [self.readerVC changeReaderScrollerDirection:XJReaderScrollerDirectionHorizontal];
    }
}

- (void)pagebar:(XJPDFThumbsPagebar *)pagebar gotoPage:(NSInteger)page {
    [self.readerVC goDocumentAtPage:page animated:NO];
}

- (void)pagebar:(XJPDFThumbsPagebar *)pagebar willGotoPage:(NSInteger)page {
    self.pageTipsLabel.text = [NSString stringWithFormat:@"%ld/%ld", page, self.readerVC.totalPageNum];
}

- (void)pdfReaderViewController:(XJPDFReaderContentViewController *)readerVC didGotoPage:(NSInteger)page {
    [self.pageBar updatePagebarWithPage:page];
}


- (UILabel *)pageTipsLabel {
    if (!_pageTipsLabel) {
        _pageTipsLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.bounds.size.width-100)/2, self.view.bounds.size.height - 130, 100, 30)];
        _pageTipsLabel.backgroundColor = [UIColor lightGrayColor];
        _pageTipsLabel.textColor = [UIColor whiteColor];
        _pageTipsLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _pageTipsLabel;
}
@end
