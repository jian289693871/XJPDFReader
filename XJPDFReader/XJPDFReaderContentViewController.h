//
//  XJReaderViewController.h
//  XJReader
//
//  Created by xuejian on 2018/6/28.
//  Copyright © 2018年 xuejian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XJPDFDocument.h"

@class XJPDFReaderContentViewController;

typedef NS_ENUM(NSUInteger, XJReaderScrollerDirection) {
    XJReaderScrollerDirectionHorizontal,
    XJReaderScrollerDirectionVertical,
};

@protocol XJPDFReaderDelegate <NSObject>
@optional
- (void)pdfReaderViewController:(XJPDFReaderContentViewController *)readerVC didGotoPage:(NSInteger)page;
- (void)pdfReaderViewController:(XJPDFReaderContentViewController *)readerVC willGotoPage:(NSInteger)page;
@end

@interface XJPDFReaderContentViewController : UIViewController
@property (nonatomic, weak) id <XJPDFReaderDelegate> delegate; 
@property (nonatomic, strong, readonly) XJPDFDocument *pdfDocument;
@property (nonatomic, assign, readonly) NSInteger totalPageNum;
@property (nonatomic, assign, readonly) NSInteger currentPageNum;
@property (nonatomic, assign, readonly) XJReaderScrollerDirection direction;
@property (nonatomic, strong, readonly) UITapGestureRecognizer *doubleTap;

- (instancetype)initWithDocument:(XJPDFDocument *)document direction:(XJReaderScrollerDirection)direction;
- (void)openDocument:(XJPDFDocument *)document direction:(XJReaderScrollerDirection)direction;

/// go documemt page, page >= 1 and page <= pdfDocument.totalPageCount
- (void)goDocumentAtPage:(NSUInteger)page animated:(BOOL)animated;
- (void)changeReaderScrollerDirection:(XJReaderScrollerDirection)direction;
@end
