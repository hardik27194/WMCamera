//
//  WMAlbumSelectionView.m
//  WMCamera
//
//  Created by leon on 11/23/15.
//  Copyright © 2015 Codoon. All rights reserved.
//

#import "WMAlbumSelectionView.h"

@interface WMAlbumSelectionView ()
@property (nonatomic, weak) IBOutlet UILabel            *lblTitle;
@property (nonatomic, weak) IBOutlet UIImageView        *arrowView;


@end

@implementation WMAlbumSelectionView

+ (instancetype)albumSelectionView {
    WMAlbumSelectionView *albumSelectionView = [[[NSBundle mainBundle] loadNibNamed:@"WMAlbumSelectionView"
                                                                              owner:self
                                                                            options:nil] firstObject];
    return albumSelectionView;
}

- (void)setAlbumName:(NSString *)albumName {
    [self.lblTitle setText:albumName];
}

- (void)rotateArrowUpAnimated:(BOOL)animated {
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    void (^ animateBlock)() = ^{
        [self.arrowView setTransform:transform];
    };
    
    if(animated) {
        [UIView animateWithDuration:0.25 animations:animateBlock];
    }
    else {
        animateBlock();
    }

}

- (void)rotateArrowDownAnimated:(BOOL)animated {
    CGAffineTransform transform = CGAffineTransformRotate(self.arrowView.transform, M_PI);
    
    void (^ animateBlock)() = ^{
        [self.arrowView setTransform:transform];
    };
    
    if(animated) {
        [UIView animateWithDuration:0.25 animations:animateBlock];
    }
    else {
        animateBlock();
    }
}

@end
