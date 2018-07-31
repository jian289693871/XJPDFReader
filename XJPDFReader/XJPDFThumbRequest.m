//
//  XJPDFThumbRequest.m
//  XJPDFReader
//
//  Created by xuejian on 2018/7/5.
//  Copyright © 2018年 xuejian. All rights reserved.
//

#import "XJPDFThumbRequest.h"
#import <CommonCrypto/CommonDigest.h>

@interface XJPDFThumbRequestQueue ()
@end

@implementation XJPDFThumbRequestQueue

+ (instancetype)shareThumbRequestQueue {
    static XJPDFThumbRequestQueue *shareQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareQueue = [[XJPDFThumbRequestQueue alloc] init];
        
    });
    return shareQueue;
}

- (void)addPDFThumbRequest:(XJPDFThumbRequest *)request {
    if (request.thumbImage) return;
    [self.queue addOperation:request.operation];
}

- (void)canclePDFThumbRequest:(XJPDFThumbRequest *)request {
    [self.queue setSuspended:YES];
    [request.operation cancel];
    request.operation = nil;
    [self.queue setSuspended:NO];
}

- (void)cancleAllPDFThumbRequest {
    [self.queue cancelAllOperations];
}

- (NSOperationQueue *)queue {
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 1;
    }
    return _queue;
}
@end

@interface XJPDFThumbRequest()
@property (nonatomic, strong) XJPDFDocument *pdfDocument;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) CGSize thumbSize;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, copy) NSString *key;
@end

@implementation XJPDFThumbRequest
- (instancetype)initWithPDFDocument:(XJPDFDocument *)pdfDocument page:(NSInteger)page thumbSize:(CGSize)thumbSize {
    self = [super init];
    if (self) {
        self.pdfDocument = pdfDocument;
        self.page = page;
        self.scale = [UIScreen mainScreen].scale;
        self.thumbSize = thumbSize;
    }
    return self;
}

- (NSString *)md5:(NSString *)text {
    const char *str = [text UTF8String];
    unsigned char result[16];
    CC_MD5( str, (int)strlen(str), result );
    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",result[0], result[1], result[2], result[3],result[4], result[5], result[6], result[7],result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]];
}

- (XJPDFThumbOperation *)operation {
    if (!_operation) {
        _operation = [[XJPDFThumbOperation alloc] initWithPDFThumbRequest:self];
    }
    return _operation;
}

- (NSString *)key {
    if (!_key) {
        _key = [NSString stringWithFormat:@"%@_%ld_%ld*%ld", [self md5:self.pdfDocument.filePath], self.page, (long)self.thumbSize.width, (long)self.thumbSize.height];
    }
    return _key;
}
@end
