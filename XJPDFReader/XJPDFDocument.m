//
//  XJPDFDocument.m
//  XJReader iOS
//
//  Created by xuejian on 2018/6/29.
//  Copyright © 2018年 xuejian. All rights reserved.
//

#import "XJPDFDocument.h"
#import "XJPDFDefines.h"

BOOL IsPdf(NSString *filePath) {
    BOOL state = NO;
    if (filePath != nil)  {
        const char *path = [filePath fileSystemRepresentation];
        int fd = open(path, O_RDONLY); // Open the file
        if (fd > 0) {
            const char sig[1024]; // File signature buffer
            ssize_t len = read(fd, (void *)&sig, sizeof(sig));
            state = (strnstr(sig, "%PDF", len) != NULL);
            close(fd); // Close the file
        }
    }
    return state;
}

CGPDFDocumentRef CGPDFDocumentCreateUsingUrl(NSURL *fileURL, NSString *password, NSError **error) {
    CFURLRef theURL = (__bridge CFURLRef)fileURL;
    CGPDFDocumentRef thePDFDocRef = NULL; // CGPDFDocument
    
    if (theURL != NULL)  {
        thePDFDocRef = CGPDFDocumentCreateWithURL(theURL);
        if (thePDFDocRef != NULL) {  // Check for non-NULL CGPDFDocumentRef
            if (CGPDFDocumentIsEncrypted(thePDFDocRef) == TRUE) {   // Encrypted
                // Try a blank password first, per Apple's Quartz PDF example
                if (CGPDFDocumentUnlockWithPassword(thePDFDocRef, "") == FALSE) {
                    // Nope, now let's try the provided password to unlock the PDF
                    if ((password != nil) && (password.length > 0)) {   // Not blank?
                        char text[128]; // char array buffer for the string conversion
                        [password getCString:text maxLength:126 encoding:NSUTF8StringEncoding];
                        
                        if (CGPDFDocumentUnlockWithPassword(thePDFDocRef, text) == FALSE) { // Log failure
                            XJPDFLog(@"CGPDFDocumentCreateUsingUrl: Unable to unlock [%@] with [%@]", theURL, password);
                        }
                    }
                }
                
                if (CGPDFDocumentIsUnlocked(thePDFDocRef) == FALSE) {   // Cleanup unlock failure
                    CGPDFDocumentRelease(thePDFDocRef);
                    thePDFDocRef = NULL;
                    *error = [NSError errorWithDomain:@"PDFErrorDomain" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"document password error"}];
                }
            }
        }
    } else {
        XJPDFLog(@"CGPDFDocumentCreateUsingUrl: theURL == NULL");
        *error = [NSError errorWithDomain:@"PDFErrorDomain" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"document url is NULL"}];
    }
    
    return thePDFDocRef;
}

@interface XJPDFDocument ()
@property (nonatomic, assign) CGPDFDocumentRef CGPDFDocument; // document ref
@property (nonatomic, assign) NSInteger totalPageCount; // document total page count
//@property (nonatomic, assign) NSInteger currentPageNumber; // document current page number
@property (nonatomic, copy) NSString *title;  // document title
@property (nonatomic, strong) NSURL *fileURL; // document file url
@property (nonatomic, copy) NSString *filePath; // document file path
@property (nonatomic, copy) NSString *password; // document password
@property (nonatomic, strong) NSDate *fileDate; // document file date
@property (nonatomic, strong) NSNumber *fileSize; // document file size(bytes)
@end

@implementation XJPDFDocument
- (void)dealloc {
    CGPDFDocumentRelease(_CGPDFDocument);
}

- (instancetype)initWithFilePath:(NSString *)filePath password:(NSString *)phrase error:(NSError **)error {
    self = [super init];
    if (self) {
        if (IsPdf(filePath) == YES) {
            _password = [phrase copy]; // Keep copy of document password
            _filePath = [filePath copy]; // Keep copy of document file path
//            _currentPageNumber = 1;
            NSError *fileError = nil;
            CGPDFDocumentRef thePDFDocRef = CGPDFDocumentCreateUsingUrl([self fileURL], _password, &fileError);
            if (thePDFDocRef != NULL)  {
                _CGPDFDocument = thePDFDocRef;
                NSInteger pageCount = CGPDFDocumentGetNumberOfPages(thePDFDocRef);
                _totalPageCount = pageCount;
                
                CGPDFDictionaryRef dict = CGPDFDocumentGetInfo(self.CGPDFDocument);
                CGPDFStringRef title = NULL;
                CGPDFDictionaryGetString(dict, "Title", &title);
                _title = (__bridge_transfer NSString *)CGPDFStringCopyTextString(title);
            } else {
                if (error) *error = fileError;
            }
            
            NSFileManager *fileManager = [NSFileManager defaultManager]; // Singleton
            NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:_filePath error:NULL];
            _fileDate = [fileAttributes objectForKey:NSFileModificationDate]; // File date
            _fileSize = [fileAttributes objectForKey:NSFileSize]; // File size (bytes)
        } else {
            if (error)  *error = [NSError errorWithDomain:@"PDFErrorDomain" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"document is not pdf"}];
            self = nil;
        }
    }
    return self;
}

- (NSURL *)fileURL {
    if (_fileURL == nil) {
        _fileURL = [[NSURL alloc] initFileURLWithPath:_filePath isDirectory:NO];
    }
    return _fileURL;
}

- (XJPDFPage *)pageAtIndex:(NSUInteger)index {
    CGPDFPageRef cgPage = CGPDFDocumentGetPage(self.CGPDFDocument, index);
    if (cgPage) {
        XJPDFPage *page = [[XJPDFPage alloc] initWithCGPDFPage:cgPage];
        return page;
    } else {
        return nil;
    }
}

@end
