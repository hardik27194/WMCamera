//
//  WMCamera.m
//  WMCamera
//
//  Created by leon on 11/6/15.
//  Copyright © 2015 Codoon. All rights reserved.
//

#import "WMCamera.h"

#import "WMMainViewController.h"
#import "WMCameraViewController.h"
#import "WMPhotosViewController.h"
#import "WMImageEditViewController.h"


@interface WMCamera ()
@property (nonatomic, weak) WMMainViewController        *mainViewController;

@end

@implementation WMCamera

#pragma mark - Life Cycle

- (id)initWithWatermarks:(NSArray *)watermarks {
    if(self = [super init]) {
        [self setNavigationBarHidden:YES animated:NO];
        [self pushViewController:({
            WMMainViewController *mainViewController    = [[WMMainViewController alloc] initWithWatermarks:watermarks];
            _mainViewController                         = mainViewController;
        }) animated:NO];
    }
    
    return self;
}

- (id)init {
    if(self = [super init]) {
        [self setNavigationBarHidden:YES animated:NO];
        [self pushViewController:({
            WMMainViewController *mainViewController    = [[WMMainViewController alloc] init];
            _mainViewController                         = mainViewController;
        }) animated:NO];
    }
    
    return self;
}

#pragma mark - Setter

- (void)setMaskType:(WMMaskType)maskType {
    _maskType                    = maskType;
    _mainViewController.maskType = maskType;
}

- (void)setCaptureDevicePosition:(AVCaptureDevicePosition)captureDevicePosition {
    _captureDevicePosition                    = captureDevicePosition;
    _mainViewController.captureDevicePosition = captureDevicePosition;
}

#pragma mark - WMCameraViewControllerOutput

- (void)cameraViewController:(WMCameraViewController *)cameraViewController
                 outputImage:(UIImage *)outputImage {
    if(_wmDelegate && [_wmDelegate respondsToSelector:@selector(camera:capturedImage:)]) {
        [_wmDelegate camera:self capturedImage:outputImage];
    }
}

- (void)cameraViewController:(WMCameraViewController *)cameraViewController
           outputCropedImage:(UIImage *)outputImage {
    if(_wmDelegate && [_wmDelegate respondsToSelector:@selector(camera:finalSynthetisedImage:)]) {
        [_wmDelegate camera:self finalSynthetisedImage:outputImage];
    }
}

#pragma mark - WMPhotosViewControllerOutput

- (void)photosViewController:(WMPhotosViewController *)photosViewController
                 outputImage:(UIImage *)outputImage {
    if(_wmDelegate && [_wmDelegate respondsToSelector:@selector(camera:cropedImage:)]) {
        [_wmDelegate camera:self cropedImage:outputImage];
    }
}

- (void)photosViewController:(WMPhotosViewController *)photosViewController
           outputCropedImage:(UIImage *)outputImage {
    if(_wmDelegate && [_wmDelegate respondsToSelector:@selector(camera:finalSynthetisedImage:)]) {
        [_wmDelegate camera:self finalSynthetisedImage:outputImage];
    }
}

#pragma mark - WMImageEditViewControllerOutput

- (void)imageEditViewController:(WMImageEditViewController *)imageEditViewController
                    outputImage:(UIImage *)outputImage {
    if(_wmDelegate && [_wmDelegate respondsToSelector:@selector(camera:finalSynthetisedImage:)]) {
        [_wmDelegate camera:self finalSynthetisedImage:outputImage];
    }
}

@end
