//
//  WMAlbumSelectionView.h
//  WMCamera
//
//  Created by leon on 11/23/15.
//  Copyright © 2015 Codoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMAlbumSelectionView : UIControl

+ (instancetype)albumSelectionView;

- (void)setAlbumName:(NSString *)albumName;

- (void)rotateArrowUpAnimated:(BOOL)animated;

- (void)rotateArrowDownAnimated:(BOOL)animated;

@end
