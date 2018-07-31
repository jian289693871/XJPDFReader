//
//  XJPDFReaderViewController.h
//  XJPDFReader
//
//  Created by xuejian on 2018/7/19.
//  Copyright © 2018年 xuejian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XJPDFReaderContentViewController.h"


/**
 下载进度回调

 @param operation 下载operation
 @param totalBytesWritten 已下载字节
 @param totalBytesExpectedToWrite 下载总字节
 */
typedef void(^DownProgressBlock)(NSOperation *operation, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite);

/**
 下载完成回调

 @param operation 下载operation
 @param location 下载文件暂存地址
 @return 下载文件保存地址，用户自定义
 */
typedef NSURL *(^DownCompletedBlock)(NSOperation *operation, NSURL *location);

/**
 下载失败回调

 @param operation 下载operation
 @param error 下载错误
 */
typedef void(^DownFailedBlock)(NSOperation *operation, NSError *error);


@interface XJPDFReaderViewController : XJPDFReaderContentViewController

/**
 打开一个远程pdf文件，如果已下载，则展示下载文件；如果未下载，则先下载

 @param url pdf文件远程地址
 @param password pdf文件密码
 @param direction 阅读器滚动方向
 @param downProgress 下载进度回调
 @param downCompleted 下载完成回调
 @param downFailed 下载失败回调
 */
- (void)openOnlinePdfUrl:(NSString *)url password:(NSString *)password direction:(XJReaderScrollerDirection)direction downProgress:(DownProgressBlock)downProgress downCompleted:(DownCompletedBlock)downCompleted downFailed:(DownFailedBlock)downFailed;

/**
 打开一个本地pdf文件

 @param pdfPath pdf本地文件地址
 @param password pdf文件密码
 @param direction 阅读器滚动方向
 @param complete 打开完成回调，error不为空，打开失败，error=nil，打开成功
 */
- (void)openLocalPdfPath:(NSString *)pdfPath password:(NSString *)password direction:(XJReaderScrollerDirection)direction complete:(void (^)(NSError *error))complete;
@end
