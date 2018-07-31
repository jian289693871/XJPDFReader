//
//  XJPDFMenoryCache.m
//  XJPDFReader
//
//  Created by xuejian on 2018/7/6.
//  Copyright © 2018年 xuejian. All rights reserved.
//

#import "XJPDFThumbMenoryCache.h"

@interface XJPDFThumbMenoryCache ()
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSCache *thumbCache;
@end

@implementation XJPDFThumbMenoryCache

+ (instancetype)shareThumbMenoryCache {
    static XJPDFThumbMenoryCache *shareCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareCache = [[XJPDFThumbMenoryCache alloc] init];
    });
    return shareCache;
}

- (void)dealloc {
    [self.queue cancelAllOperations];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 1;
        
        self.thumbCache = [NSCache new];
        [self.thumbCache setName:@"PDFThumbCache"];
        [self.thumbCache setTotalCostLimit:2097152];
    }
    return self;
}

- (UIImage *)thumbImageWithRequest:(XJPDFThumbRequest *)request imageView:(UIImageView *)imageView {
    UIImage *image = [self.thumbCache objectForKey:request.key];
    if (image) return image;
    
    XJPDFThumbOperation *operation = [[XJPDFThumbOperation alloc] initWithPDFThumbRequest:request];
    operation.requestComplete = ^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.image = image;
            [self.thumbCache setObject:image forKey:request.key];
        });
    };
    [self.queue addOperation:operation];
    return nil;
}

@end
