//
//  WMWaterMarkCollectionView.h
//  Blast
//
//  Created by leon on 8/16/16.
//  Copyright © 2016 codoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WMWatermarkProtocol;
@protocol WMWaterMarkSelectionDelegate;
@interface WMWaterMarkCollectionView : UIView
@property (nonatomic, weak) id<WMWaterMarkSelectionDelegate>        delegate;
@property (nonatomic, copy) NSArray<id<WMWatermarkProtocol>>        *watermarks;
@property (nonatomic, assign) NSInteger                             selectedIndex;

+ (instancetype)waterMarkCollectionView;

@end



@protocol WMWaterMarkSelectionDelegate <NSObject>
@optional

- (void)waterMarkCollectionView:(WMWaterMarkCollectionView *)wmCollectionView
          willSelectedWatermark:(id<WMWatermarkProtocol>)watermark
                        atIndex:(NSUInteger)aIndex;

- (void)waterMarkCollectionView:(WMWaterMarkCollectionView *)wmCollectionView
           didSelectedWatermark:(id<WMWatermarkProtocol>)watermark
                        atIndex:(NSUInteger)aIndex;

- (void)waterMarkCollectionViewDidClearWatermark:(WMWaterMarkCollectionView *)wmCollectionView;

@end
