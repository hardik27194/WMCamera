//
//  WMAlbumView.h
//  WMCamera
//
//  Created by leon on 11/23/15.
//  Copyright © 2015 Codoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WMAlbumViewDelegate;
@class ALAssetsGroup;
@interface WMAlbumView : UIView
@property (nonatomic, weak) id<WMAlbumViewDelegate>             delegate;

@property (nonatomic, strong) NSArray<ALAssetsGroup *>          *albums;

+ (instancetype)albumView;

@end



@protocol WMAlbumViewDelegate <NSObject>

- (void)albumView:(WMAlbumView *)albumView didSelectedIndex:(NSUInteger)aIndex;

@end