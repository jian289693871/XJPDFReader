#import <UIKit/UIKit.h>
#import "XJPDFDocument.h"

@class ReaderThumbView;
@class XJPDFThumbsPagebar;
@class ReaderTrackControl;
@class ReaderPagebarThumb;
@class ReaderDocument;

@protocol XJPDFThumbsPagebarDelegate <NSObject>
@optional
- (void)pagebar:(XJPDFThumbsPagebar *)pagebar willGotoPage:(NSInteger)page;

@required
- (void)pagebar:(XJPDFThumbsPagebar *)pagebar gotoPage:(NSInteger)page;

@end

@interface XJPDFThumbsPagebar : UIView
@property (nonatomic, weak, readwrite) id <XJPDFThumbsPagebarDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame document:(XJPDFDocument *)pdfDocument;

- (void)updatePagebarWithPage:(NSInteger)page;
- (void)hidePagebar;
- (void)showPagebar;
@end

#pragma mark -

@interface ReaderTrackControl : UIControl
@property (nonatomic, assign, readonly) CGFloat value;
@end

#pragma mark -
@interface ReaderPagebarThumb : UIView
@property (nonatomic, strong) UIImageView *imageView;
@property (atomic, strong, readwrite) NSOperation *operation;
@property (nonatomic, assign, readwrite) NSUInteger targetTag;

- (instancetype)initWithFrame:(CGRect)frame small:(BOOL)small;

- (void)showImage:(UIImage *)image;
- (void)showTouched:(BOOL)touched;
- (void)reuse;

@end

#pragma mark -
@interface ReaderPagebarShadow : UIView

@end

