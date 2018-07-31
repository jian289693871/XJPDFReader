//
//  XJPDFDownloaderStatusView.h
//  XJPDFReader
//
//  Created by xuejian on 2018/7/18.
//  Copyright © 2018年 xuejian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XJPDFDownloaderStatusView : UIView
@property (nonatomic, assign) double progress;
@property (nonatomic, copy  ) NSString *errorDesc;
@end
