//
//  WMImageCropView.h
//  WMImageCroper
//
//  Created by leon on 8/5/16.
//  Copyright © 2016 codoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMImageCropView : UIView
@property (nonatomic, strong, readwrite) UIImage         *image;

- (void)relayoutImage;

- (UIImage *)currentCropedImage;

@end
