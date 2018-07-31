//
//  XJPDFThumbDocumentCell.h
//  XJPDFReader
//
//  Created by xuejian on 2018/7/3.
//  Copyright © 2018年 xuejian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XJPDFPage.h"
#import "XJPDFThumbRequest.h"

#define kXJPDFThumbDocumentImageWidth (((MIN(UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height))-18*2-36*2)/3.0)
#define kXJPDFThumbDocumentImageHeight (kXJPDFThumbDocumentImageWidth*7/5.0)
#define kXJPDFThumbDocumentLabelHeight 42
#define kXJPDFThumbDocumentCellSize CGSizeMake(kXJPDFThumbDocumentImageWidth, kXJPDFThumbDocumentImageHeight+kXJPDFThumbDocumentLabelHeight)

@interface XJPDFThumbDocumentCell : UICollectionViewCell
@property (nonatomic, strong) XJPDFThumbRequest *thumbRequest;
@property (nonatomic, assign) BOOL isSelectedPage;
@end
