//
//  XJPDFThumbReaderViewController.h
//  XJPDFReader
//
//  Created by xuejian on 2018/7/3.
//  Copyright © 2018年 xuejian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XJPDFDocument.h"

@interface XJPDFThumbReaderViewController : UIViewController

// 缩略图回调
@property (nonatomic, copy) void (^thumbReaderPageDidSelected)(XJPDFThumbReaderViewController *vc, NSInteger selectPage);

/**
 pdf缩略图初始化

 @param pdfDocument pdf文件
 @param selectedPage 选中页码
 @return 对象
 */
- (instancetype)initWitPDFDocument:(XJPDFDocument *)pdfDocument selectedPage:(NSInteger)selectedPage;
@end
