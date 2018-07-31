//
//  XJPDFDownloaderStatusView.m
//  XJPDFReader
//
//  Created by xuejian on 2018/7/18.
//  Copyright © 2018年 xuejian. All rights reserved.
//

#import "XJPDFDownloaderStatusView.h"
#import "XJProgressBar.h"

@interface XJPDFDownloaderStatusView ()
@property (nonatomic, strong) UIImageView *progressView;
@property (nonatomic, strong) XJProgressBar *progressBar;
@property (nonatomic, strong) UILabel *progressLabel;

@property (nonatomic, strong) UILabel *errorLabel;
@end


@implementation XJPDFDownloaderStatusView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
//        [self addSubview:self.progressView];
        [self addSubview:self.progressBar];
        [self addSubview:self.progressLabel];
        [self addSubview:self.errorLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.bounds.size.width - 60;
    CGFloat height = 6;
    CGFloat x = (self.bounds.size.width-width)/2;
    CGFloat y = (self.bounds.size.height-height)/2;
//    self.progressView.frame = CGRectMake(x, y, width, height);
    self.progressBar.frame = CGRectMake(x, y, width, height);
    self.progressLabel.frame = CGRectMake(x, y-34, width, 23);
    self.errorLabel.frame = CGRectMake(x, (self.bounds.size.height-20)/2, width, 20);
}

- (void)setProgress:(double)progress{
    self.progressLabel.text=[NSString stringWithFormat:@"正在打开 %d%%",(int)(progress*100)];
    self.progressBar.progress=progress;
}

- (void)setErrorDesc:(NSString *)errorDesc {
    _errorDesc = errorDesc;
    self.errorLabel.text = _errorDesc;
    if (errorDesc) {
//        self.progressView.hidden = YES;
        self.progressBar.hidden = YES;
        self.progressLabel.hidden = YES;
        self.errorLabel.hidden = NO;
    } else {
//        self.progressView.hidden = NO;
        self.progressBar.hidden = NO;
        self.progressLabel.hidden = NO;
        self.errorLabel.hidden = YES;
    }
}


#pragma mark - Getter
//- (UIImageView*)progressView{
//    if (!_progressView) {
//        NSBundle *bundle = [NSBundle bundleForClass:self.class];
//        UIImage *image = [UIImage imageNamed:@"pdf_pdownload_progress_bar" inBundle:bundle compatibleWithTraitCollection:nil];
//        _progressView=[[UIImageView alloc]initWithImage:image];
//    }
//    return _progressView;
//}

- (XJProgressBar*)progressBar{
    if (!_progressBar) {
        _progressBar=[[XJProgressBar alloc]init];
        _progressBar.progress=0;
        _progressBar.backgroundColor=[UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
        _progressBar.trackTintColor=[UIColor clearColor];
        _progressBar.type=XJProgressBarTypeRounded;
        _progressBar.cornerRadius=3;
        _progressBar.hideGloss=YES;
        UIColor *color1 = [UIColor colorWithRed:255/255.0 green:100/255.0 blue:20/255.0 alpha:1];
        UIColor *color2 = [UIColor colorWithRed:255/255.0 green:100/255.0 blue:20/255.0 alpha:1];
        _progressBar.progressTintColors=@[color1, color2];
        _progressBar.hideStripes=YES;
        _progressBar.layer.cornerRadius = 3;
//        _progressBar.layer.borderWidth = 0.5;
//        _progressBar.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
        _progressBar.clipsToBounds = YES;
        
    }
    return _progressBar;
}
- (UILabel*)progressLabel{
    if (!_progressLabel) {
        _progressLabel=[[UILabel alloc]init];
        _progressLabel.font=[UIFont systemFontOfSize:14];
        _progressLabel.textColor=[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];;
        _progressLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _progressLabel;
}

- (UILabel*)errorLabel{
    if (!_errorLabel) {
        _errorLabel=[[UILabel alloc]init];
        _errorLabel.font=[UIFont systemFontOfSize:16];
        _errorLabel.textColor=[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
        _errorLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _errorLabel;
}
@end
