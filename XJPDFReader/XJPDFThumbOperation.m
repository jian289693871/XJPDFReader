//
//  XJPDFThumbOperation.m
//  XJPDFReader
//
//  Created by xuejian on 2018/7/5.
//  Copyright © 2018年 xuejian. All rights reserved.
//

#import "XJPDFThumbOperation.h"
#import "XJPDFThumbRequest.h"

@interface XJPDFThumbOperation ()
@property (nonatomic, weak) XJPDFThumbRequest *thumbRequest;
@end

@implementation XJPDFThumbOperation
- (instancetype)initWithPDFThumbRequest:(XJPDFThumbRequest *)request {
    self = [super init];
    if (self) {
        self.thumbRequest = request;
    }
    return self;
}

- (void)cancel {
    [super cancel];
}


- (void)main {
    CGPDFDocumentRef thePDFDocRef = CGPDFDocumentCreateUsingUrl(self.thumbRequest.pdfDocument.fileURL, self.thumbRequest.pdfDocument.password, nil);
    CGImageRef imageRef = NULL;

    if (thePDFDocRef != NULL) {
        CGPDFPageRef thePDFPageRef = CGPDFDocumentGetPage(thePDFDocRef, self.thumbRequest.page);//pdfPage.CGPDFPage;
        if (thePDFPageRef != NULL) {
            CGFloat thumb_w = self.thumbRequest.thumbSize.width; // Maximum thumb width
            CGFloat thumb_h = self.thumbRequest.thumbSize.height; // Maximum thumb height

            CGRect cropBoxRect = CGPDFPageGetBoxRect(thePDFPageRef, kCGPDFCropBox);
            CGRect mediaBoxRect = CGPDFPageGetBoxRect(thePDFPageRef, kCGPDFMediaBox);
            CGRect effectiveRect = CGRectIntersection(cropBoxRect, mediaBoxRect);

            NSInteger pageRotate = CGPDFPageGetRotationAngle(thePDFPageRef); // Angle
            CGFloat page_w = 0.0f; CGFloat page_h = 0.0f; // Rotated page size

            switch (pageRotate) {
                default: // Default case
                case 0: case 180: {
                    page_w = effectiveRect.size.width;
                    page_h = effectiveRect.size.height;
                    break;
                }

                case 90: case 270: {
                    page_h = effectiveRect.size.width;
                    page_w = effectiveRect.size.height;
                    break;
                }
            }

            CGFloat scale_w = (thumb_w / page_w); // Width scale
            CGFloat scale_h = (thumb_h / page_h); // Height scale

            CGFloat scale = 0.0f; // Page to target thumb size scale

            if (page_h > page_w)
                scale = ((thumb_h > thumb_w) ? scale_w : scale_h); // Portrait
            else
                scale = ((thumb_h < thumb_w) ? scale_h : scale_w); // Landscape

            NSInteger target_w = (page_w * scale); // Integer target thumb width
            NSInteger target_h = (page_h * scale); // Integer target thumb height

            if (target_w % 2) target_w--; if (target_h % 2) target_h--; // Even

            target_w *= self.thumbRequest.scale;
            target_h *= self.thumbRequest.scale;

            CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB(); // RGB color space

            CGBitmapInfo bmi = (kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst);

            CGContextRef context = CGBitmapContextCreate(NULL, target_w, target_h, 8, 0, rgb, bmi);

            if (context != NULL) {
                CGRect thumbRect = CGRectMake(0.0f, 0.0f, target_w, target_h); // Target thumb rect
                CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f); CGContextFillRect(context, thumbRect); // White fill
                CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(thePDFPageRef, kCGPDFCropBox, thumbRect, 0, true));
                CGContextDrawPDFPage(context, thePDFPageRef); // Render the PDF page into the custom CGBitmap context
                imageRef = CGBitmapContextCreateImage(context); // Create CGImage from custom CGBitmap context
                CGContextRelease(context); // Release custom CGBitmap context reference
            }
            CGColorSpaceRelease(rgb); // Release device RGB color space reference
        }
        
        CGPDFDocumentRelease(thePDFDocRef); // Release CGPDFDocumentRef reference
    }

    if (imageRef != NULL)  {
        UIImage *image = [UIImage imageWithCGImage:imageRef scale:self.thumbRequest.scale orientation:UIImageOrientationUp];
        if (self.isCancelled == NO) {
            self.thumbRequest.thumbImage = image;
            if (self.requestComplete) self.requestComplete(image);
        }
        CGImageRelease(imageRef); // Release CGImage reference
    }
}

/*
 UIGraphicsBeginImageContextWithOptions(self.thumbRequest.thumbSize, NO, 1.0);
 CGContextRef context = UIGraphicsGetCurrentContext();
 CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f); // White
 CGContextFillRect(context, CGContextGetClipBoundingBox(context)); // Fill
 CGContextTranslateCTM(context, 0.0f, self.thumbRequest.thumbSize.height);
 CGContextScaleCTM(context, 1.0f, -1.0f);
 CGAffineTransform transform = CGPDFPageGetDrawingTransform(thePDFPageRef, kCGPDFCropBox, CGRectMake(0, 0, self.thumbRequest.thumbSize.width, self.thumbRequest.thumbSize.height), 0, true);
 CGContextConcatCTM(context, transform);
 CGContextDrawPDFPage(context, thePDFPageRef); // Render the PDF page into the context
 UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
 if (self.isCancelled == NO) {
 self.thumbRequest.thumbImage = image;
 }
 UIGraphicsEndImageContext();
 */
@end
