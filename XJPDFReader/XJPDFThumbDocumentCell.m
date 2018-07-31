//
//  XJPDFThumbDocumentCell.m
//  XJPDFReader
//
//  Created by xuejian on 2018/7/3.
//  Copyright © 2018年 xuejian. All rights reserved.
//

#import "XJPDFThumbDocumentCell.h"
#import "XJPDFPageContentView.h"

@interface XJPDFThumbDocumentCell ()
@property (nonatomic, strong) UILabel *pageLabel;
@property (nonatomic, strong) UIImageView *thumbImageView;
@property (nonatomic, strong) UILabel *pageLabel2;
@end

@implementation XJPDFThumbDocumentCell

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"thumbRequest.thumbImage"];
    [self removeObserver:self forKeyPath:@"thumbRequest.page"];
    [self removeObserver:self forKeyPath:@"isSelectedPage"];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.contentView.backgroundColor = [UIColor clearColor];
        _pageLabel = [[UILabel alloc] init];
        _pageLabel.textColor = [UIColor blackColor];
        _pageLabel.font = [UIFont boldSystemFontOfSize:20];
        _pageLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_pageLabel];
        
        _thumbImageView = [[UIImageView alloc] init];
        _thumbImageView.layer.borderColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0].CGColor;
        _thumbImageView.layer.borderWidth = 0.5;
        [self.contentView addSubview:_thumbImageView];
        
        _pageLabel2 = [[UILabel alloc] init];
        _pageLabel2.textColor = [UIColor blackColor];
        _pageLabel2.font = [UIFont systemFontOfSize:16];
        _pageLabel2.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_pageLabel2];

        [self addObserver:self forKeyPath:@"thumbRequest.thumbImage" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"thumbRequest.page" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"isSelectedPage" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _thumbImageView.frame = CGRectMake(0, 0, kXJPDFThumbDocumentImageWidth, kXJPDFThumbDocumentImageHeight);
    _pageLabel.frame = _thumbImageView.bounds;
    _pageLabel2.frame = CGRectMake(0, kXJPDFThumbDocumentImageHeight, kXJPDFThumbDocumentImageWidth, kXJPDFThumbDocumentLabelHeight);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"thumbRequest.thumbImage"])  {
        id image = [change objectForKey:NSKeyValueChangeNewKey];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([image isKindOfClass:[UIImage class]]) {
                self.thumbImageView.image = image;
            } else {
                self.thumbImageView.image = nil;
            }
        });
        
    } else if ([keyPath isEqualToString:@"thumbRequest.page"])  {
        NSInteger page = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        _pageLabel.text = [NSString stringWithFormat:@"%ld", (long)page];
        _pageLabel2.text = [NSString stringWithFormat:@"%ld", (long)page];
    } else if ([keyPath isEqualToString:@"isSelectedPage"]) {
        BOOL isSelectedPage = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        if (isSelectedPage) {
            _thumbImageView.layer.borderColor = [UIColor colorWithRed:255/255.0 green:100/255.0 blue:20/255.0 alpha:1/1.0].CGColor;
            _thumbImageView.layer.borderWidth = 2;
        } else {
            _thumbImageView.layer.borderColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0].CGColor;
            _thumbImageView.layer.borderWidth = 0.5;
        }
    }
}

@end
