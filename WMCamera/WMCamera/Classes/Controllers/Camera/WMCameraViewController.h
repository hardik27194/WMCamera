//
//  WMCameraViewController.h
//  WMCamera
//
//  Created by leon on 11/5/15.
//  Copyright © 2015 Codoon. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "WMAbstractViewController.h"
#import "WMTypes.h"

@interface WMCameraViewController : WMAbstractViewController
@property (nonatomic, strong, readwrite) NSArray                    *watermarks;
@property (nonatomic, assign, readwrite) WMMaskType                 maskType;
@property (nonatomic, assign, readwrite) AVCaptureDevicePosition    captureDevicePosition;
@property (nonatomic, assign, getter = isSupportWatermarks) BOOL    supportWatermarks;

@end


@protocol WMCameraViewControllerOutput <NSObject>

- (void)cameraViewController:(WMCameraViewController *)cameraViewController
                 outputImage:(UIImage *)outputImage;

- (void)cameraViewController:(WMCameraViewController *)cameraViewController
           outputCropedImage:(UIImage *)outputImage;

@end
