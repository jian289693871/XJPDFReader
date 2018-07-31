//
//  XJPDFThumbOperation.h
//  XJPDFReader
//
//  Created by xuejian on 2018/7/5.
//  Copyright © 2018年 xuejian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XJPDFDocument.h"
@class XJPDFThumbRequest;

typedef void(^PDFThumbRequestComplete)(UIImage *image);

@interface XJPDFThumbOperation : NSOperation
@property (nonatomic, copy) PDFThumbRequestComplete requestComplete;

- (instancetype)initWithPDFThumbRequest:(XJPDFThumbRequest *)request;

@end
