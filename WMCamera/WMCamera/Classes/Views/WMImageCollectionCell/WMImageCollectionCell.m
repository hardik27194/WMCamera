//
//  WMImageCollectionCell.m
//  Blast
//
//  Created by leon on 8/17/16.
//  Copyright © 2016 codoon. All rights reserved.
//

#import "WMImageCollectionCell.h"

@interface WMImageCollectionCell ()
@property (nonatomic, weak) IBOutlet UIImageView        *imageView;

@end

@implementation WMImageCollectionCell

- (UIImage *)selectedBackgroundImage {
    static UIImage *selectedBackgroundImage;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        selectedBackgroundImage = [UIImage imageNamed:@"ic_selected_rectangle" inBundle:bundle compatibleWithTraitCollection:nil];
    });
    
    return selectedBackgroundImage;
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    UIImageView *selectedBackground = [[UIImageView alloc] initWithImage:[self selectedBackgroundImage]];
    self.selectedBackgroundView = selectedBackground;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if(selected) {
        self.imageView.backgroundColor     = [UIColor colorWithWhite:17.0f / 255.0f alpha:1.0f];
        self.selectedBackgroundView.hidden = NO;
        [self bringSubviewToFront:self.selectedBackgroundView];
    }
    else {
        self.imageView.backgroundColor     = [UIColor colorWithWhite:38.0f / 255.0f alpha:1.0f];
        self.selectedBackgroundView.hidden = YES;
        [self sendSubviewToBack:self.selectedBackgroundView];
    }
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

- (void)setImageContentFillMode:(UIViewContentMode)mode {
    self.imageView.contentMode = mode;
}

@end
