//
//  XJPDFThumbRequest.h
//  XJPDFReader
//
//  Created by xuejian on 2018/7/5.
//  Copyright © 2018年 xuejian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XJPDFDocument.h"
#import "XJPDFThumbOperation.h"


@class XJPDFThumbRequest;

@interface XJPDFThumbRequestQueue : NSObject

@property (nonatomic,strong) NSOperationQueue *queue;

+ (instancetype)shareThumbRequestQueue;

- (void)addPDFThumbRequest:(XJPDFThumbRequest *)request;
- (void)canclePDFThumbRequest:(XJPDFThumbRequest *)request;
- (void)cancleAllPDFThumbRequest;
@end

@interface XJPDFThumbRequest : NSObject
@property (nonatomic, strong, readonly) XJPDFDocument *pdfDocument;
@property (nonatomic, assign, readonly) NSInteger page;
@property (nonatomic, assign, readonly) CGFloat scale;
@property (nonatomic, assign, readonly) CGSize thumbSize;
@property (nonatomic, copy, readonly) NSString *key;
@property (nonatomic, strong) UIImage *thumbImage;
@property (nonatomic, strong) XJPDFThumbOperation *operation;

- (instancetype)initWithPDFDocument:(XJPDFDocument *)pdfDocument page:(NSInteger)page thumbSize:(CGSize)thumbSize;
@end
