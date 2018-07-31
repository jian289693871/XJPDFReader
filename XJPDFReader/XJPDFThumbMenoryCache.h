//
//  XJPDFMenoryCache.h
//  XJPDFReader
//
//  Created by xuejian on 2018/7/6.
//  Copyright © 2018年 xuejian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XJPDFThumbRequest.h"

@interface XJPDFThumbMenoryCache : NSObject
+ (instancetype)shareThumbMenoryCache;
- (UIImage *)thumbImageWithRequest:(XJPDFThumbRequest *)request imageView:(UIImageView *)imageView;
@end
