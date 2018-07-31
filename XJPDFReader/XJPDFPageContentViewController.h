//
//  XJPDFPageContentViewController.h
//  Reader
//
//  Created by xuejian on 2018/7/2.
//  Copyright © 2018年 xuejian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XJPDFPage.h"
#import "XJPDFPageContentView.h"

@interface XJPDFPageContentViewController : UIViewController
@property (nonatomic, strong,readonly) XJPDFPage *pdfPage;

- (instancetype)initWithPdfPage:(XJPDFPage *)pdfPage;

- (void)doubleTapped:(UITapGestureRecognizer *)recognizer;  // 双击放大/缩小
@end
