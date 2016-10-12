//
//  WMPhotoCell.m
//  WMCamera
//
//  Created by leon on 11/23/15.
//  Copyright © 2015 Codoon. All rights reserved.
//

#import "WMPhotoCell.h"

@interface WMPhotoCell()
@property (nonatomic, weak) IBOutlet UIImageView        *imageView;
@property (nonatomic, weak) IBOutlet UIButton           *checkView;

@end

@implementation WMPhotoCell

- (void)setPhoto:(UIImage *)photo {
    [self.imageView setHighlightedImage:nil];
    [self.imageView setImage:photo];
}


- (void)setSelected:(BOOL)selected {
    [self.checkView setSelected:selected];
}

@end
