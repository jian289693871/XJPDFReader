//
//  XJPDFPage.m
//  Reader
//
//  Created by xuejian on 2018/6/30.
//  Copyright © 2018年 xuejian. All rights reserved.
//

#import "XJPDFPage.h"

@interface XJPDFPage ()
@property (nonatomic, assign) CGPDFPageRef CGPDFPage;
@property (nonatomic, assign) NSUInteger pageNum;
@property (nonatomic, assign) CGRect rect;
@property (nonatomic, strong) NSOperationQueue *queue;
@end

@implementation XJPDFPage
- (void)dealloc {
    CGPDFPageRelease(_CGPDFPage);
}

- (instancetype)initWithCGPDFPage:(CGPDFPageRef)CGPDFPage {
    self = [super init];
    if (self) {
        _CGPDFPage = CGPDFPageRetain(CGPDFPage);
        _pageNum = (NSUInteger)CGPDFPageGetPageNumber(self.CGPDFPage);
        _rect = CGPDFPageGetBoxRect(self.CGPDFPage, kCGPDFMediaBox);
    }
    return self;
}

- (void)drawInRect:(CGRect)rect inContext:(CGContextRef)context {
    CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f); // White
    CGContextFillRect(context, CGContextGetClipBoundingBox(context)); // Fill
    CGContextTranslateCTM(context, 0.0f, rect.size.height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGAffineTransform transform = CGPDFPageGetDrawingTransform(self.CGPDFPage, kCGPDFCropBox, rect, 0, true);
    CGContextConcatCTM(context, transform);
    CGContextDrawPDFPage(context, self.CGPDFPage); // Render the PDF page into the context
}

- (UIImage *)thumbnailImageWithSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 1.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawInRect:CGRectMake(0, 0, size.width, size.height) inContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (NSOperationQueue *)queue {
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
    }
    return _queue;
}
@end
