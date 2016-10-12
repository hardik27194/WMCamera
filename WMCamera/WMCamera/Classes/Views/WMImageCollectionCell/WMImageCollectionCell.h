//
//  WMImageCollectionCell.h
//  Blast
//
//  Created by leon on 8/17/16.
//  Copyright © 2016 codoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMImageCollectionCell : UICollectionViewCell
@property (nonatomic, strong) UIImage           *image;

- (void)setImageContentFillMode:(UIViewContentMode)mode;

@end
