#import "XJPDFThumbsPagebar.h"
#import "XJPDFThumbMenoryCache.h"

#import <QuartzCore/QuartzCore.h>

@interface XJPDFThumbsPagebar ()
@property (nonatomic, strong) XJPDFDocument *pdfDocument;
@property (nonatomic, assign) NSInteger currentPage;
@end

@implementation XJPDFThumbsPagebar {
    ReaderTrackControl *trackControl;
    NSMutableDictionary *miniThumbViews;
    ReaderPagebarThumb *pageThumbView;
    UILabel *pageNumberLabel;
    UIView *pageNumberView;
    NSTimer *enableTimer;
    NSTimer *trackTimer;
}

#pragma mark - Constants

#define THUMB_SMALL_GAP 2
#define THUMB_SMALL_WIDTH 22
#define THUMB_SMALL_HEIGHT 28

#define THUMB_LARGE_WIDTH 32
#define THUMB_LARGE_HEIGHT 42

#define PAGE_NUMBER_WIDTH 96.0f
#define PAGE_NUMBER_HEIGHT 30.0f

#define PAGE_NUMBER_SPACE_SMALL 16.0f
#define PAGE_NUMBER_SPACE_LARGE 32.0f

#define SHADOW_HEIGHT 4.0f

#pragma mark - Properties

@synthesize delegate;

#pragma mark - ReaderMainPagebar class methods

+ (Class)layerClass
{
#if (READER_FLAT_UI == FALSE) // Option
    return [CAGradientLayer class];
#else
    return [CALayer class];
#endif // end of READER_FLAT_UI Option
}

#pragma mark - ReaderMainPagebar instance methods

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame document:nil];
}

- (void)updatePageThumbView:(NSInteger)page {
    NSInteger pages = self.pdfDocument.totalPageCount;

    if (pages > 1) {
        CGFloat controlWidth = trackControl.bounds.size.width;
        CGFloat useableWidth = (controlWidth - THUMB_LARGE_WIDTH);
        CGFloat stride = (useableWidth / (pages - 1)); // Page stride
        NSInteger X = (stride * (page - 1)); CGFloat pageThumbX = X;
        CGRect pageThumbRect = pageThumbView.frame; // Current frame
        if (pageThumbX != pageThumbRect.origin.x) {
            pageThumbRect.origin.x = pageThumbX; // The new X position
            pageThumbView.frame = pageThumbRect; // Update the frame
        }
    }

    if (page != pageThumbView.tag) {
        if ([self.delegate respondsToSelector:@selector(pagebar:willGotoPage:)]) {
            [self.delegate pagebar:self willGotoPage:page];
        }
        pageThumbView.tag = page;
        [pageThumbView reuse]; // Reuse the thumb view
        CGSize size = CGSizeMake(THUMB_LARGE_WIDTH, THUMB_LARGE_HEIGHT); // Maximum thumb size

        XJPDFThumbRequest *request = [[XJPDFThumbRequest alloc] initWithPDFDocument:self.pdfDocument page:page thumbSize:size];
        UIImage *image = [[XJPDFThumbMenoryCache shareThumbMenoryCache] thumbImageWithRequest:request imageView:pageThumbView.imageView];
        UIImage *thumb = ([image isKindOfClass:[UIImage class]] ? image : nil);
        [pageThumbView showImage:thumb];
        
    }
}

- (instancetype)initWithFrame:(CGRect)frame document:(XJPDFDocument *)pdfDocument {
    assert(pdfDocument != nil); // Must have a valid ReaderDocument

    if ((self = [super initWithFrame:frame])) {
        self.currentPage = 1;
        self.autoresizesSubviews = YES;
        self.userInteractionEnabled = YES;
        self.contentMode = UIViewContentModeRedraw;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;

        if ([self.layer isKindOfClass:[CAGradientLayer class]]) {
            self.backgroundColor = [UIColor clearColor];

            CAGradientLayer *layer = (CAGradientLayer *)self.layer;
            UIColor *liteColor = [UIColor colorWithWhite:0.82f alpha:0.8f];
            UIColor *darkColor = [UIColor colorWithWhite:0.32f alpha:0.8f];
            layer.colors = [NSArray arrayWithObjects:(id)liteColor.CGColor, (id)darkColor.CGColor, nil];
            CGRect shadowRect = self.bounds; shadowRect.size.height = SHADOW_HEIGHT; shadowRect.origin.y -= shadowRect.size.height;
            ReaderPagebarShadow *shadowView = [[ReaderPagebarShadow alloc] initWithFrame:shadowRect];
            [self addSubview:shadowView]; // Add shadow to toolbar
        } else {
            self.backgroundColor = [UIColor colorWithWhite:0.94f alpha:0.94f];

            CGRect lineRect = self.bounds; lineRect.size.height = 1.0f; lineRect.origin.y -= lineRect.size.height;

            UIView *lineView = [[UIView alloc] initWithFrame:lineRect];
            lineView.autoresizesSubviews = NO;
            lineView.userInteractionEnabled = NO;
            lineView.contentMode = UIViewContentModeRedraw;
            lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            lineView.backgroundColor = [UIColor colorWithWhite:0.64f alpha:0.94f];
            [self addSubview:lineView];
        }
        
        trackControl = [[ReaderTrackControl alloc] initWithFrame:self.bounds]; // Track control view
        [trackControl addTarget:self action:@selector(trackViewTouchDown:) forControlEvents:UIControlEventTouchDown];
        [trackControl addTarget:self action:@selector(trackViewValueChanged:) forControlEvents:UIControlEventValueChanged];
        [trackControl addTarget:self action:@selector(trackViewTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
        [trackControl addTarget:self action:@selector(trackViewTouchUp:) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:trackControl]; // Add the track control and thumbs view

        self.pdfDocument = pdfDocument;

//        [self updatePageNumberText:self.currentPage];

        miniThumbViews = [NSMutableDictionary new]; // Small thumbs
    }

    return self;
}

- (void)removeFromSuperview {
    [trackTimer invalidate]; [enableTimer invalidate];
    [super removeFromSuperview];
}

- (void)layoutSubviews {
    CGRect controlRect = CGRectInset(self.bounds, 4.0f, 0.0f);
    CGFloat thumbWidth = (THUMB_SMALL_WIDTH + THUMB_SMALL_GAP);
    NSInteger thumbs = (controlRect.size.width / thumbWidth);
    NSInteger pages = self.pdfDocument.totalPageCount; // Pages
    if (thumbs > pages) thumbs = pages; // No more than total pages
    CGFloat controlWidth = ((thumbs * thumbWidth) - THUMB_SMALL_GAP);
    controlRect.size.width = controlWidth; // Update control width
    CGFloat widthDelta = (self.bounds.size.width - controlWidth);
    NSInteger X = (widthDelta * 0.5f); controlRect.origin.x = X;
    trackControl.frame = controlRect; // Update track control frame
    if (pageThumbView == nil) {
        CGFloat heightDelta = (controlRect.size.height - THUMB_LARGE_HEIGHT);
        NSInteger thumbY = (heightDelta * 0.5f); NSInteger thumbX = 0; // Thumb X, Y
        CGRect thumbRect = CGRectMake(thumbX, thumbY, THUMB_LARGE_WIDTH, THUMB_LARGE_HEIGHT);
        pageThumbView = [[ReaderPagebarThumb alloc] initWithFrame:thumbRect]; // Create the thumb view
        pageThumbView.layer.zPosition = 1.0f; // Z position so that it sits on top of the small thumbs
        [trackControl addSubview:pageThumbView]; // Add as the first subview of the track control
    }

    [self updatePageThumbView:self.currentPage]; // Update page thumb view

    NSInteger strideThumbs = (thumbs - 1); if (strideThumbs < 1) strideThumbs = 1;
    CGFloat stride = ((CGFloat)pages / (CGFloat)strideThumbs); // Page stride
    CGFloat heightDelta = (controlRect.size.height - THUMB_SMALL_HEIGHT);
    NSInteger thumbY = (heightDelta * 0.5f); NSInteger thumbX = 0; // Initial X, Y
    CGRect thumbRect = CGRectMake(thumbX, thumbY, THUMB_SMALL_WIDTH, THUMB_SMALL_HEIGHT);
    NSMutableDictionary *thumbsToHide = [miniThumbViews mutableCopy];

    for (NSInteger thumb = 0; thumb < thumbs; thumb++) {
        NSInteger page = ((stride * thumb) + 1); if (page > pages) page = pages; // Page

        NSNumber *key = [NSNumber numberWithInteger:page]; // Page number key for thumb view

        ReaderPagebarThumb *smallThumbView = [miniThumbViews objectForKey:key]; // Thumb view

        if (smallThumbView == nil) {
            CGSize size = CGSizeMake(THUMB_SMALL_WIDTH, THUMB_SMALL_HEIGHT); // Maximum thumb size

            smallThumbView = [[ReaderPagebarThumb alloc] initWithFrame:thumbRect small:YES]; // Create a small thumb view

            XJPDFThumbRequest *request = [[XJPDFThumbRequest alloc] initWithPDFDocument:self.pdfDocument page:page thumbSize:size];
            UIImage *image = [[XJPDFThumbMenoryCache shareThumbMenoryCache] thumbImageWithRequest:request imageView:smallThumbView.imageView];
            
            if ([image isKindOfClass:[UIImage class]]) [smallThumbView showImage:image]; // Use thumb image from cache

            [trackControl addSubview:smallThumbView];
            [miniThumbViews setObject:smallThumbView forKey:key];
            
        } else {
            smallThumbView.hidden = NO; [thumbsToHide removeObjectForKey:key];

            if (CGRectEqualToRect(smallThumbView.frame, thumbRect) == false) {
                smallThumbView.frame = thumbRect; // Update thumb frame
            }
        }

        thumbRect.origin.x += thumbWidth; // Next thumb X position
    }

    [thumbsToHide enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
            ReaderPagebarThumb *thumb = object; thumb.hidden = YES;
        }
    ];
}

- (void)updatePagebarWithPage:(NSInteger)page {
    if (self.hidden) return;
    if (page < 1 || page > self.pdfDocument.totalPageCount) return;
    
    [self updatePagebarViewWithPage:page];
}

- (void)updatePagebarViewWithPage:(NSInteger)page {
//    [self updatePageNumberText:page]; // Update page number text
    [self updatePageThumbView:page]; // Update page thumb view
}


- (void)hidePagebar {
    if (self.hidden == NO)  {
        [UIView animateWithDuration:0.25 delay:0.0
            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction animations:^(void) {
                self.alpha = 0.0f;
            } completion:^(BOOL finished) {
                self.hidden = YES;
            }
        ];
    }
}

- (void)showPagebar {
    if (self.hidden == YES)  {
        [self updatePagebarViewWithPage:1];

        [UIView animateWithDuration:0.25 delay:0.0
            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction animations:^(void) {
                self.hidden = NO;
                self.alpha = 1.0f;
            }
            completion:NULL
        ];
    }
}

#pragma mark - ReaderTrackControl action methods

- (void)trackTimerFired:(NSTimer *)timer {
    [trackTimer invalidate]; trackTimer = nil; // Cleanup timer
    [delegate pagebar:self gotoPage:trackControl.tag]; // Go to document page
}

- (void)enableTimerFired:(NSTimer *)timer {
    [enableTimer invalidate]; enableTimer = nil; // Cleanup timer

    trackControl.userInteractionEnabled = YES; // Enable track control interaction
}

- (void)restartTrackTimer {
    if (trackTimer != nil) { [trackTimer invalidate]; trackTimer = nil; } // Invalidate and release previous timer

    trackTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(trackTimerFired:) userInfo:nil repeats:NO];
}

- (void)startEnableTimer {
    if (enableTimer != nil) { [enableTimer invalidate]; enableTimer = nil; } // Invalidate and release previous timer

    enableTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(enableTimerFired:) userInfo:nil repeats:NO];
}

- (NSInteger)trackViewPageNumber:(ReaderTrackControl *)trackView {
    CGFloat controlWidth = trackView.bounds.size.width; // View width

    CGFloat stride = (controlWidth / self.pdfDocument.totalPageCount);

    NSInteger page = (trackView.value / stride); // Integer page number

    return (page + 1); // + 1
}

- (void)trackViewTouchDown:(ReaderTrackControl *)trackView {
    NSInteger page = [self trackViewPageNumber:trackView]; // Page

    if (page != self.currentPage) {
        [self updatePageThumbView:page]; // Update page thumb view
        [self restartTrackTimer]; // Start the track timer
    }

    self.currentPage = page;
    trackView.tag = page; // Start page tracking
}

- (void)trackViewValueChanged:(ReaderTrackControl *)trackView {
    NSInteger page = [self trackViewPageNumber:trackView]; // Page
    if (page != trackView.tag)  {
        [self updatePageThumbView:page]; // Update page thumb view
        trackView.tag = page; // Update the page tracking tag
        self.currentPage = page;

        [self restartTrackTimer]; // Restart the track timer
    }
}

- (void)trackViewTouchUp:(ReaderTrackControl *)trackView {
    [trackTimer invalidate];
    trackTimer = nil; // Cleanup
    
    trackView.userInteractionEnabled = NO; // Disable track control interaction
    [delegate pagebar:self gotoPage:trackView.tag]; // Go to document page
    [self startEnableTimer]; // Start track control enable timer
    
    self.currentPage = 0;
    trackView.tag = 0; // Reset page tracking
}

@end

#pragma mark -

//
//    ReaderTrackControl class implementation
//

@interface ReaderTrackControl ()
@property (nonatomic, assign) CGFloat value;
@end

@implementation ReaderTrackControl

#pragma mark - ReaderTrackControl instance methods

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.autoresizesSubviews = NO;
        self.userInteractionEnabled = YES;
        self.contentMode = UIViewContentModeRedraw;
        self.autoresizingMask = UIViewAutoresizingNone;
        self.backgroundColor = [UIColor clearColor];
        self.exclusiveTouch = YES;
    }

    return self;
}

- (CGFloat)limitValue:(CGFloat)valueX {
    CGFloat minX = self.bounds.origin.x; // 0.0f;
    CGFloat maxX = (self.bounds.size.width - 1.0f);

    if (valueX < minX) valueX = minX; // Minimum X
    if (valueX > maxX) valueX = maxX; // Maximum X

    return valueX;
}

#pragma mark - UIControl subclass methods

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint point = [touch locationInView:self]; // Touch point
    _value = [self limitValue:point.x]; // Limit control value
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    if (self.touchInside == YES) {
        CGPoint point = [touch locationInView:touch.view]; // Touch point
        CGFloat x = [self limitValue:point.x]; // Potential new control value

        if (x != _value) {
            _value = x; [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint point = [touch locationInView:self]; // Touch point
    _value = [self limitValue:point.x]; // Limit control value
}

@end

#pragma mark -

@implementation ReaderPagebarThumb
#pragma mark - ReaderPagebarThumb instance methods

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame small:NO];
}

- (instancetype)initWithFrame:(CGRect)frame small:(BOOL)small {
    if ((self = [super initWithFrame:frame])) {
        self.autoresizesSubviews = NO;
        self.userInteractionEnabled = NO;
        self.contentMode = UIViewContentModeRedraw;
        self.autoresizingMask = UIViewAutoresizingNone;
        self.backgroundColor = [UIColor clearColor];

        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.autoresizesSubviews = NO;
        _imageView.userInteractionEnabled = NO;
        _imageView.autoresizingMask = UIViewAutoresizingNone;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;

        [self addSubview:_imageView];

        CGFloat value = (small ? 0.6f : 0.7f); // Size based alpha value
        UIColor *background = [UIColor colorWithWhite:0.8f alpha:value];
        self.backgroundColor = background; _imageView.backgroundColor = background;
        
        _imageView.layer.borderColor = [UIColor colorWithWhite:0.4f alpha:0.6f].CGColor;
        _imageView.layer.borderWidth = 1.0f; // Give the thumb image view a border
    }

    return self;
}

- (void)showImage:(UIImage *)image {
    _imageView.image = image; // Show image
}

- (void)showTouched:(BOOL)touched {
    // Implemented by ReaderThumbView subclass
}

- (void)removeFromSuperview {
    _targetTag = 0; // Clear target tag
    [self.operation cancel]; // Cancel operation
    [super removeFromSuperview]; // Remove view
}

- (void)reuse {
    _targetTag = 0; // Clear target tag
    [self.operation cancel]; // Cancel operation
    _imageView.image = nil; // Release image
}

@end

#pragma mark -

@implementation ReaderPagebarShadow

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.autoresizesSubviews = NO;
        self.userInteractionEnabled = NO;
        self.contentMode = UIViewContentModeRedraw;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor clearColor];

        CAGradientLayer *layer = (CAGradientLayer *)self.layer;
        UIColor *blackColor = [UIColor colorWithWhite:0.42f alpha:1.0f];
        UIColor *clearColor = [UIColor colorWithWhite:0.42f alpha:0.0f];
        layer.colors = [NSArray arrayWithObjects:(id)clearColor.CGColor, (id)blackColor.CGColor, nil];
    }

    return self;
}

@end
