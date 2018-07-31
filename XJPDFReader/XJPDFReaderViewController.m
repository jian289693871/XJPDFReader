//
//  XJPDFReaderViewController.m
//  XJPDFReader
//
//  Created by xuejian on 2018/7/19.
//  Copyright © 2018年 xuejian. All rights reserved.
//

#import "XJPDFReaderViewController.h"
#import "XJPDFReaderContentViewController.h"
#import "XJPDFDownloaderStatusView.h"
#if __has_include(<XXDownloader/XXDownloader.h>)
#import <XXDownloader/XXDownloader.h>
#else
#import "XXDownloader.h"
#endif

@interface XJPDFReaderViewController () <NSURLSessionDelegate>
@property (nonatomic, strong) XJPDFDownloaderStatusView *statusView;
@property (nonatomic, strong) XJPDFReaderContentViewController *pdfContentVC;

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) XXDownloaderOperation *operation;

@property (nonatomic, copy) DownProgressBlock progressBlock;
@property (nonatomic, copy) DownCompletedBlock completeBlock;
@property (nonatomic, copy) DownFailedBlock failedBlock;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, assign) XJReaderScrollerDirection eDirection;

@property (nonatomic, strong) NSURL *location;
@end

@implementation XJPDFReaderViewController

- (void)dealloc {
    self.progressBlock = nil;
    self.completeBlock = nil;
    self.failedBlock = nil;
    
    [self.operation cancel];
    [self.operationQueue cancelAllOperations];
    self.operation = nil;
    self.operationQueue = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.statusView];
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.statusView.frame = self.view.bounds;
}

#pragma mark - open
- (void)openOnlinePdfUrl:(NSString *)url password:(NSString *)password direction:(XJReaderScrollerDirection)direction downProgress:(DownProgressBlock)downProgress downCompleted:(DownCompletedBlock)downCompleted downFailed:(DownFailedBlock)downFailed {
    if (!url || url.length==0) {
        self.statusView.errorDesc = @"pdf文件地址错误";
        self.statusView.hidden = NO;
        return;
    }
    
    self.eDirection = direction;
    self.password = password;
    self.progressBlock = downProgress;
    self.completeBlock = downCompleted;
    self.failedBlock = downFailed;
    
    
    self.statusView.hidden = NO;
    self.statusView.errorDesc = nil;
    self.statusView.progress = 0;

    NSString *tempFileName = [XXDownloaderTools md5:url];
    NSString *targetPath = [NSTemporaryDirectory() stringByAppendingPathComponent:tempFileName];
    __weak typeof(self) weakSelf = self;
    self.operation = [[XXDownloaderOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] targetPath:targetPath shouldResume:YES needRetry:YES];
    self.operation.operationDidStartBlock = ^(XXDownloaderOperation *operation, NSURLSessionTask *task) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.view bringSubviewToFront:strongSelf.statusView];
        strongSelf.statusView.hidden = NO;
        strongSelf.statusView.errorDesc = nil;
    };
    self.operation.operationProgressBlock = ^(XXDownloaderOperation *operation, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.statusView.progress = totalBytesWritten / (double)totalBytesExpectedToWrite;
        if (strongSelf.progressBlock) strongSelf.progressBlock(operation, totalBytesWritten, totalBytesExpectedToWrite);
    };
    self.operation.operationCompletionBlock = ^(XXDownloaderOperation *operation, NSString *fileLocation) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.statusView.hidden = YES;
        NSURL *expectLocation = [NSURL fileURLWithPath:fileLocation];
        if (strongSelf.completeBlock) {
            expectLocation = strongSelf.completeBlock(operation, expectLocation);
        }
        [strongSelf openLocalPdfPath:expectLocation.path password:strongSelf.password direction:strongSelf.eDirection complete:NULL];
    };
    self.operation.operationFailerBlock = ^(XXDownloaderOperation *operation, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            strongSelf.statusView.hidden = NO;
            strongSelf.statusView.errorDesc = NSLocalizedString(@"PDF加载失败", nil);
            if (strongSelf.failedBlock) strongSelf.failedBlock(operation, error);
        } else {
            strongSelf.statusView.hidden = YES;
            strongSelf.statusView.errorDesc = nil;
        }
    };
    [self.operationQueue addOperation:self.operation];
    
}

- (void)openLocalPdfPath:(NSString *)pdfPath password:(NSString *)password direction:(XJReaderScrollerDirection)direction complete:(void (^)(NSError *error))complete {
    self.statusView.errorDesc = nil;
    self.statusView.hidden = YES;
    
    NSError *error = nil;
    XJPDFDocument *document = [[XJPDFDocument alloc] initWithFilePath:pdfPath password:password error:&error];
    if (error) {
        [self.view bringSubviewToFront:self.statusView];
        self.statusView.hidden = NO;
        self.statusView.errorDesc = NSLocalizedString(@"PDF加载失败", nil);
    } else {
        [self openDocument:document direction:direction];
    }
    if (complete) complete(error);
}


#pragma mark - Getter
- (XJPDFDownloaderStatusView *)statusView {
    if (!_statusView) {
        _statusView = [[XJPDFDownloaderStatusView alloc] initWithFrame:CGRectZero];
        _statusView.progress = 0;
        _statusView.hidden = YES;
    }
    return _statusView;
}



@end
