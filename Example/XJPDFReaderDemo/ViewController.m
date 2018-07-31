//
//  ViewController.m
//  XJPDFReaderDemo
//
//  Created by xuejian on 2018/7/31.
//  Copyright © 2018年 xuejian. All rights reserved.
//

#import "ViewController.h"
#import "XJPDFReader/XJPDFReader.h"
#import "PDFDemoViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pdf1:(UIButton *)sender {
    PDFDemoViewController *vc = [[PDFDemoViewController alloc] init];
    vc.pdfName = @"a2";
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)pdf2:(UIButton *)sender {
    PDFDemoViewController *vc = [[PDFDemoViewController alloc] init];
    vc.pdfName = @"sample";
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)netPdf:(UIButton *)sender {
//    NSString *pdfUrl = @"https://testserver.comein.cn/comein-files//document/2018-07-14/f709b2aa-ae0e-4129-b67a-bdc8bfdca2b7/f709b2aa.pdf";
//    
//    XJPDFReaderViewController *vc = [[XJPDFReaderViewController alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
//    [vc openOnlinePdfUrl:pdfUrl password:@"!qaz@wsx#edc" direction:XJReaderScrollerDirectionVertical downProgress:^(NSOperation *operation, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
//
//    } downCompleted:^NSURL *(NSOperation *operation, NSURL *location) {
//        NSString *libDir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)firstObject];
//        NSString *pdfDir = [libDir stringByAppendingPathComponent:@"PDFs"];
//        NSString *filePath = [pdfDir stringByAppendingPathComponent:@"123"];
//        return [NSURL fileURLWithPath:filePath];
//    } downFailed:^(NSOperation *operation, NSError *error) {
//
//    }];
//    [self.navigationController pushViewController:vc animated:YES];
}
@end
