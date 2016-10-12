//
//  WMImageEditViewController.h
//  Blast
//
//  Created by leon on 8/15/16.
//  Copyright © 2016 codoon. All rights reserved.
//

#import "WMAbstractViewController.h"

@interface WMImageEditViewController : WMAbstractViewController
@property (nonatomic, strong, readonly) UIImage             *image;
@property (nonatomic, strong, readwrite) NSArray            *watermarks;
@property (nonatomic, assign,readwrite) NSInteger           selectedWatermarkIndex;

- (id)initWithImage:(UIImage *)aImage;

@end


@protocol WMImageEditViewControllerOutput <NSObject>

- (void)imageEditViewController:(WMImageEditViewController *)imageEditViewController
                    outputImage:(UIImage *)outputImage;

@end
