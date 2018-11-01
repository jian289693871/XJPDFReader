//
//  XJPDFThumbReaderViewController.m
//  XJPDFReader
//
//  Created by xuejian on 2018/7/3.
//  Copyright © 2018年 xuejian. All rights reserved.
//

#import "XJPDFThumbReaderViewController.h"
#import "XJPDFThumbDocumentCell.h"
#import "XJPDFThumbOperation.h"

@interface XJPDFThumbReaderViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
@property (nonatomic, strong) XJPDFDocument *pdfDocument;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableDictionary *thumbRequests;
@property (nonatomic, assign) CGSize thumbSize;
@property (nonatomic, assign) NSInteger selectedPage;
@end

@implementation XJPDFThumbReaderViewController

- (void)dealloc {
    [[XJPDFThumbRequestQueue shareThumbRequestQueue] cancleAllPDFThumbRequest];
}

- (instancetype)initWitPDFDocument:(XJPDFDocument *)pdfDocument selectedPage:(NSInteger)selectedPage{
    self = [super init];
    if (self) {
        self.pdfDocument = pdfDocument;
        self.thumbRequests = [[NSMutableDictionary alloc] initWithCapacity:self.pdfDocument.totalPageCount];
        self.selectedPage = selectedPage;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1/1.0];
    [self.view addSubview:self.collectionView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.collectionView.frame = self.view.bounds;
}

#pragma mark - Delegate
#pragma mark -- UICollectionview Delegate
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(18, 18, 18, 18);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.pdfDocument.totalPageCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    XJPDFThumbDocumentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.tag = indexPath.row;
    XJPDFThumbRequest *request = [self.thumbRequests objectForKey:@(indexPath.row+1)];
    if (!request) {
        request = [[XJPDFThumbRequest alloc] initWithPDFDocument:self.pdfDocument page:indexPath.row+1 thumbSize:kXJPDFThumbDocumentCellSize];
        [self.thumbRequests setObject:request forKey:@(indexPath.row+1)];
    }
    cell.thumbRequest =  request;
    cell.isSelectedPage = ((indexPath.row+1) == self.selectedPage) ? YES : NO;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if (self.thumbReaderPageDidSelected) self.thumbReaderPageDidSelected(self, indexPath.row+1);
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    XJPDFThumbRequest *request = [self.thumbRequests objectForKey:@(indexPath.row+1)];
    [[XJPDFThumbRequestQueue shareThumbRequestQueue] addPDFThumbRequest:request];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(nonnull UICollectionViewCell *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    XJPDFThumbRequest *request = [self.thumbRequests objectForKey:@(indexPath.row+1)];
    [[XJPDFThumbRequestQueue shareThumbRequestQueue] canclePDFThumbRequest:request];
}

#pragma mark - Getter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout  = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.itemSize = kXJPDFThumbDocumentCellSize;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor =  [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1/1.0];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.userInteractionEnabled = YES;
         [_collectionView registerClass:[XJPDFThumbDocumentCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return _collectionView;
}

@end
