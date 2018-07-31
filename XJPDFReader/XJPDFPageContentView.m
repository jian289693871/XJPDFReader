//
//  XJPDFContentView.m
//  XJReader iOS
//
//  Created by xuejian on 2018/6/29.
//  Copyright © 2018年 xuejian. All rights reserved.
//

#import "XJPDFPageContentView.h"
#import "XJPDFContentTiledLayer.h"

@interface XJPDFPageContentView ()
@end

@implementation XJPDFPageContentView

- (void)removeFromSuperview {
    self.layer.delegate = nil;
    [super removeFromSuperview];
}

+ (Class)layerClass {
    return [XJPDFContentTiledLayer class];
}

- (void)drawLayer:(CATiledLayer *)layer inContext:(CGContextRef)context {
    [self.pdfPage drawInRect:layer.bounds inContext:context];
}
@end
