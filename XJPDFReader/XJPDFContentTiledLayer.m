//
//  XJPDFContentTiledLayer.m
//  XJReader iOS
//
//  Created by xuejian on 2018/6/29.
//  Copyright © 2018年 xuejian. All rights reserved.
//

#import "XJPDFContentTiledLayer.h"

@implementation XJPDFContentTiledLayer
#pragma mark - Constants

#define LEVELS_OF_DETAIL 16

#pragma mark - ReaderContentTile class methods

+ (CFTimeInterval)fadeDuration {
    return 0.001;
}

#pragma mark - ReaderContentTile instance methods

- (instancetype)init {
    if ((self = [super init])) {
        self.levelsOfDetail = LEVELS_OF_DETAIL; // Zoom levels
        self.levelsOfDetailBias = (LEVELS_OF_DETAIL - 1); // Bias
        UIScreen *mainScreen = [UIScreen mainScreen]; // Main screen
        CGFloat screenScale = [mainScreen scale]; // Main screen scale
        CGRect screenBounds = [mainScreen bounds]; // Main screen bounds

        CGFloat w_pixels = (screenBounds.size.width * screenScale);
        CGFloat h_pixels = (screenBounds.size.height * screenScale);
        CGFloat max = ((w_pixels < h_pixels) ? h_pixels : w_pixels);
        CGFloat sizeOfTiles = ((max < 512.0f) ? 512.0f : 1024.0f);
        self.tileSize = CGSizeMake(sizeOfTiles, sizeOfTiles);
    }
    return self;
}
@end
