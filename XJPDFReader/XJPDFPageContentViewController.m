//
//  XJPDFPageContentViewController.m
//  Reader
//
//  Created by xuejian on 2018/7/2.
//  Copyright © 2018年 xuejian. All rights reserved.
//

#import "XJPDFPageContentViewController.h"

@interface XJPDFPageContentViewController () <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *contentScrollerView;
@property (nonatomic, strong) XJPDFPageContentView *pdfContentView;
@property (nonatomic, strong) XJPDFPage *pdfPage;
@property (nonatomic, strong) UIImageView *lowResolutionView;
@property (nonatomic, assign) BOOL isFirstDidLayout;
@end

@implementation XJPDFPageContentViewController

- (instancetype)initWithPdfPage:(XJPDFPage *)pdfPage {
    self = [super init];
    if (self) {
        self.isFirstDidLayout = YES;
        self.pdfPage = pdfPage;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
//    [self.view addGestureRecognizer:({
//        UITapGestureRecognizer *tapGestureRecognizer =
//        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
//        tapGestureRecognizer.numberOfTapsRequired = 2;
//        tapGestureRecognizer;
//    })];
    
    _contentScrollerView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _contentScrollerView.contentSize = self.view.bounds.size;
    _contentScrollerView.delegate = self;
    _contentScrollerView.showsVerticalScrollIndicator = NO;
    _contentScrollerView.showsHorizontalScrollIndicator = NO;
    _contentScrollerView.alwaysBounceVertical = NO;
    _contentScrollerView.alwaysBounceHorizontal = NO;
    _contentScrollerView.scrollsToTop = NO;
    _contentScrollerView.maximumZoomScale = 16;
    _contentScrollerView.minimumZoomScale = 1;
    [self.view addSubview:_contentScrollerView];
    
    _pdfContentView = [[XJPDFPageContentView alloc] initWithFrame:self.view.bounds];
    _pdfContentView.pdfPage = self.pdfPage;
    [_contentScrollerView addSubview:_pdfContentView];

    _lowResolutionView = [[UIImageView alloc] init];
    [self.view insertSubview:_lowResolutionView atIndex:0];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.contentScrollerView.frame = self.view.bounds;
    self.contentScrollerView.contentSize = self.view.bounds.size;
    self.pdfContentView.frame = self.view.bounds;
    [self viewDidLayoutSubviewsOnece];
}

- (void)viewDidLayoutSubviewsOnece {
    if (self.isFirstDidLayout) {
        self.lowResolutionView.frame = self.view.bounds;
        UIImage *lowResolutionImage = [self.pdfPage thumbnailImageWithSize:self.lowResolutionView.bounds.size];
        self.lowResolutionView.image = lowResolutionImage;
        self.isFirstDidLayout = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.lowResolutionView.hidden = YES;
            [self.lowResolutionView removeFromSuperview];
            self.lowResolutionView = nil;
        });
    }
}

#pragma mark Target Action
- (void)doubleTapped:(UITapGestureRecognizer *)recognizer {
    if (self.contentScrollerView.zoomScale == 1.0) {
        const CGFloat zoom = 2.0;
        CGPoint point = [recognizer locationInView:self.view];
        CGFloat width = CGRectGetWidth(self.view.frame) / zoom;
        CGFloat height = width * (CGRectGetHeight(self.view.frame) / CGRectGetWidth(self.view.frame));
        CGFloat x = MAX(1.0, point.x - width / 2.0);
        CGFloat y = MAX(1.0, point.y - height / 2.0);
        [self.contentScrollerView zoomToRect:CGRectMake(x, y, width, height) animated:YES];
    } else {
        [self.contentScrollerView setZoomScale:1.0 animated:YES];
    }
}

#pragma mark - Delegate
#pragma mark -- UIScrollerView Delegate
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    if (self.lowResolutionView) {
        self.lowResolutionView.hidden = YES;
        [self.lowResolutionView removeFromSuperview];
        self.lowResolutionView = nil;
    }
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.pdfContentView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat xcenter = scrollView.center.x , ycenter = scrollView.center.y;
    xcenter = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width/2 : xcenter;
    ycenter = scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height/2 : ycenter;
    [self.pdfContentView setCenter:CGPointMake(xcenter, ycenter)];
}

@end
