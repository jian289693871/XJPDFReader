//
//  XJPDFPage.h
//  Reader
//
//  Created by xuejian on 2018/6/30.
//  Copyright © 2018年 xuejian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface XJPDFPage : NSObject
@property (nonatomic, assign, readonly) CGPDFPageRef CGPDFPage; // pdf page ref
@property (nonatomic, assign, readonly) NSUInteger pageNum;   // pdf current page num
@property (nonatomic, assign, readonly) CGRect rect; // pdf page rect

- (instancetype)initWithCGPDFPage:(CGPDFPageRef)CGPDFPage;

- (void)drawInRect:(CGRect)rect inContext:(CGContextRef)context;
- (UIImage *)thumbnailImageWithSize:(CGSize)size;
@end
