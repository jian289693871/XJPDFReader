//
//  XJReaderViewController.m
//  XJReader
//
//  Created by xuejian on 2018/6/28.
//  Copyright © 2018年 xuejian. All rights reserved.
//

#import "XJPDFReaderContentViewController.h"
#import "XJPDFPageContentViewController.h"


@interface XJPDFReaderContentViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>
@property (nonatomic, strong) XJPDFDocument *pdfDocument;
@property (nonatomic, assign) NSInteger totalPageNum;
@property (nonatomic, assign) NSInteger currentPageNum;
@property (nonatomic, assign) XJReaderScrollerDirection direction;
@property (nonatomic, strong) UIPageViewController *pageViewController;

@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;
@property (nonatomic, strong) XJPDFPageContentViewController *currentPageContentVC;
@end

@implementation XJPDFReaderContentViewController

static inline UIPageViewControllerNavigationDirection PageViewNavigationDirection(XJReaderScrollerDirection direction) {
    return direction == XJReaderScrollerDirectionHorizontal ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
}

static inline UIPageViewControllerNavigationOrientation PageViewNavigationOrientation(XJReaderScrollerDirection direction) {
    return direction == XJReaderScrollerDirectionHorizontal ? UIPageViewControllerNavigationOrientationHorizontal : UIPageViewControllerNavigationOrientationVertical;
}

//- (instancetype)init NS_UNAVAILABLE {
//    return nil;
//}

- (instancetype)initWithDocument:(XJPDFDocument *)document direction:(XJReaderScrollerDirection)direction {
    self = [super init];
    if (self) {
        self.pdfDocument = document;
        self.direction = direction;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    if (self.pdfDocument) {
        [self openDocument:self.pdfDocument direction:self.direction];
    }
    
    self.doubleTap = ({
        UITapGestureRecognizer *tapGestureRecognizer =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
        tapGestureRecognizer.numberOfTapsRequired = 2;
        tapGestureRecognizer;
    });
    [self.view addGestureRecognizer:self.doubleTap];
}

#pragma mark - Open
- (void)openDocument:(XJPDFDocument *)document direction:(XJReaderScrollerDirection)direction {
    if (self.pdfDocument != document) {
        self.pdfDocument = document;
    }
    
    if (self.pageViewController) {
        // 移除之前的控制视图
        [self.pageViewController.view removeFromSuperview];
        [self.pageViewController removeFromParentViewController];
        self.pageViewController = nil;
    }
    
    self.direction = direction;
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:PageViewNavigationOrientation(self.direction) options:@{UIPageViewControllerOptionInterPageSpacingKey: @(10)}];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    self.pageViewController.view.frame = self.view.bounds;
    
//    self.currentPageNum = 1;
    self.totalPageNum = self.pdfDocument.totalPageCount;
    [self goDocumentAtPage:1 animated:NO];
}

- (void)openDocument:(XJPDFDocument *)document {
    [self openDocument:document direction:XJReaderScrollerDirectionHorizontal];
}

- (void)changeReaderScrollerDirection:(XJReaderScrollerDirection)direction {
    if (self.direction == direction) return;
    
    if (self.pageViewController) {
        // 移除之前的控制视图
        [self.pageViewController.view removeFromSuperview];
        [self.pageViewController removeFromParentViewController];
        self.pageViewController = nil;
    }
    
    self.direction = direction;
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:PageViewNavigationOrientation(self.direction) options:@{UIPageViewControllerOptionInterPageSpacingKey: @(10)}];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    self.pageViewController.view.frame = self.view.bounds;
    
    [self goDocumentAtPage:self.currentPageNum animated:NO];
}

#pragma mark - Target Action
- (void)doubleTapped:(UITapGestureRecognizer *)gesture {
    [self.currentPageContentVC doubleTapped:gesture];
}

#pragma mark - Delegate
#pragma mark -- UIPageViewControllerDataSource Delegate
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if (self.currentPageNum == 1) return nil;
    
    return [self pageViewControllerAtIndex:self.currentPageNum - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    return [self pageViewControllerAtIndex:self.currentPageNum + 1];
}

#pragma mark -- UIPageViewController Delegate
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    XJPDFPageContentViewController *vc = pageViewController.viewControllers.firstObject;
    self.currentPageNum = vc.pdfPage.pageNum;
    self.currentPageContentVC = vc;
    if ([self.delegate respondsToSelector:@selector(pdfReaderViewController:didGotoPage:)]) {
        [self.delegate pdfReaderViewController:self didGotoPage:self.currentPageNum];
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    XJPDFPageContentViewController *contentVc = (XJPDFPageContentViewController *)[pendingViewControllers firstObject];
    if (contentVc) {
        if ([self.delegate respondsToSelector:@selector(pdfReaderViewController:willGotoPage:)]) {
            [self.delegate pdfReaderViewController:self willGotoPage:contentVc.pdfPage.pageNum];
        }
    }
}


#pragma mark - Init PDFPageViewController
- (XJPDFPageContentViewController *)pageViewControllerAtIndex:(NSUInteger)index {
    XJPDFPage *page = [self.pdfDocument pageAtIndex:index];
    if (!page) return nil;

    XJPDFPageContentViewController *vc = [[XJPDFPageContentViewController alloc] initWithPdfPage:page];
    return vc;
}


#pragma mark -
- (void)goDocumentAtPage:(NSUInteger)page animated:(BOOL)animated {
    if (page < 1 || page > self.pdfDocument.totalPageCount) return;
    
    UIPageViewControllerNavigationDirection direction = PageViewNavigationDirection(self.direction);
    NSArray *viewControllers = @[[self pageViewControllerAtIndex:page]];
    self.currentPageContentVC = [viewControllers firstObject];
    __weak UIPageViewController *pvc = self.pageViewController;
    [pvc setViewControllers:viewControllers direction:direction animated:animated completion:^(BOOL finished) {
         if (animated) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [pvc setViewControllers:viewControllers direction:direction animated:NO completion:nil];
             });
         }
    }];
    self.currentPageNum = page;
    if ([self.delegate respondsToSelector:@selector(pdfReaderViewController:didGotoPage:)]) {
        [self.delegate pdfReaderViewController:self didGotoPage:self.currentPageNum];
    }
}
@end
