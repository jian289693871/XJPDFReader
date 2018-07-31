//
//  XJPDFDocument.h
//  XJReader iOS
//
//  Created by xuejian on 2018/6/29.
//  Copyright © 2018年 xuejian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XJPDFPage.h"

CGPDFDocumentRef CGPDFDocumentCreateUsingUrl(NSURL *fileURL, NSString *password, NSError **error);

@interface XJPDFDocument : NSObject
@property (nonatomic, assign, readonly) CGPDFDocumentRef CGPDFDocument; // document ref
@property (nonatomic, assign, readonly) NSInteger totalPageCount; // document total page count
@property (nonatomic, copy, readonly) NSString *title;  // document title
@property (nonatomic, strong, readonly) NSURL *fileURL; // document file url
@property (nonatomic, copy, readonly) NSString *filePath; // document file path
@property (nonatomic, copy, readonly) NSString *password; // document password
@property (nonatomic, strong, readonly) NSDate *fileDate; // document file modification date
@property (nonatomic, strong, readonly) NSNumber *fileSize; // document file size(bytes)

- (instancetype)initWithFilePath:(NSString *)filePath password:(NSString *)phrase error:(NSError **)error;

- (XJPDFPage *)pageAtIndex:(NSUInteger)index;


@end
