//
//  WMPhotosViewController.h
//  WMImageCroper
//
//  Created by leon on 8/3/16.
//  Copyright © 2016 codoon. All rights reserved.
//

#import "WMAbstractViewController.h"
#import "WMTypes.h"

@interface WMPhotosViewController : WMAbstractViewController
@property (nonatomic, strong, readwrite) NSArray                        *watermarks;
@property (nonatomic, assign, readwrite) WMMaskType                     maskType;
@property (nonatomic, assign, getter=isSupportWatermarks) BOOL          supportWatermarks;

@end


@protocol WMPhotosViewControllerOutput <NSObject>

- (void)photosViewController:(WMPhotosViewController *)photosViewController
                 outputImage:(UIImage *)outputImage;

- (void)photosViewController:(WMPhotosViewController *)photosViewController
           outputCropedImage:(UIImage *)outputImage;

@end
