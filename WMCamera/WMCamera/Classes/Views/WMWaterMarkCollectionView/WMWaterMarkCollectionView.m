//
//  WMWaterMarkCollectionView.m
//  Blast
//
//  Created by leon on 8/16/16.
//  Copyright © 2016 codoon. All rights reserved.
//

#import "WMWaterMarkCollectionView.h"
#import "WMImageCollectionCell.h"

#import "WMWatermarkProtocol.h"


NSString * const kWatermarkCollectionCellId     = @"WMImageCollectionCell";

@interface WMWaterMarkCollectionView () <UICollectionViewDataSource>
@property (nonatomic, weak) IBOutlet UICollectionView       *collectionView;

@end

@implementation WMWaterMarkCollectionView

+ (instancetype)waterMarkCollectionView {
    WMWaterMarkCollectionView *waterMarkCollectionView = [[[NSBundle mainBundle] loadNibNamed:@"WMWaterMarkCollectionView"
                                                                                        owner:self
                                                                                      options:nil] firstObject];
    return waterMarkCollectionView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self commonInit];
}

- (void)commonInit {
    _selectedIndex = -1;
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([WMImageCollectionCell class])
                                bundle:nil];
    [self.collectionView registerNib:nib
          forCellWithReuseIdentifier:kWatermarkCollectionCellId];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    if(_selectedIndex < [self collectionView:self.collectionView numberOfItemsInSection:0]) {
        [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:_selectedIndex + 1 inSection:0]
                                          animated:YES
                                    scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.watermarks.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WMImageCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kWatermarkCollectionCellId
                                                                           forIndexPath:indexPath];
    [cell setImageContentFillMode:UIViewContentModeScaleAspectFit];

    if(indexPath.row == 0) {
        [cell setImage:[UIImage imageNamed:@"ic_empty_watermark"]];
    }
    else if(indexPath.row - 1 < self.watermarks.count) {
        id<WMWatermarkProtocol> watermark = self.watermarks[indexPath.row - 1];
        [cell setImage:watermark.imgPreview];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0) {
        _selectedIndex = -1;
        if(_delegate && [_delegate respondsToSelector:@selector(waterMarkCollectionViewDidClearWatermark:)]) {
            [_delegate waterMarkCollectionViewDidClearWatermark:self];
        }
        return;
    }
    
    NSUInteger index = indexPath.row - 1;
    if(index >= self.watermarks.count) {
        return;
    }
    
    id<WMWatermarkProtocol> watermark = self.watermarks[index];
    if(_delegate && [_delegate respondsToSelector:@selector(waterMarkCollectionView:willSelectedWatermark:atIndex:)]) {
        [_delegate waterMarkCollectionView:self willSelectedWatermark:watermark atIndex:index];
    }
    _selectedIndex = index;
    if(_delegate && [_delegate respondsToSelector:@selector(waterMarkCollectionView:didSelectedWatermark:atIndex:)]) {
        [_delegate waterMarkCollectionView:self didSelectedWatermark:watermark atIndex:index];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(MIN(collectionView.frame.size.height, 90.0), collectionView.frame.size.height);
}

@end
