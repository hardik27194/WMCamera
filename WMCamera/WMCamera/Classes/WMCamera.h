//
//  WMCamera.h
//  WMCamera
//
//  Created by leon on 11/6/15.
//  Copyright © 2015 Codoon. All rights reserved.
//

#import <GPUImage/GPUImage.h>
#import "WMTypes.h"


@protocol WMCameraDelegate;

@interface WMCamera : UINavigationController
@property (nonatomic, weak, readwrite)  id<WMCameraDelegate>      _Nullable wmDelegate;
@property (nonatomic, assign, readwrite) WMMaskType                         maskType;
@property (nonatomic, assign, readwrite) AVCaptureDevicePosition            captureDevicePosition;

// 带水印，即使watermarks参数为nil也会有默认水印供选择
- (nonnull id)initWithWatermarks:(nullable NSArray *)watermarks;

// 不带水印，拍照或者选择相片后立即技术水印相机，不再走水印选择流程
- (nonnull id)init;

@end


@protocol WMCameraDelegate <NSObject>
@optional

// 拍照回调
- (void)camera:(nonnull WMCamera *)camera capturedImage:(nullable UIImage *)capturedImage;

// 相册图片选定回调
- (void)camera:(nonnull WMCamera *)camera cropedImage:(nullable UIImage *)capturedImage;

// 最终合成图片回调
- (void)camera:(nonnull WMCamera *)camera finalSynthetisedImage:(nullable UIImage *)synthetisedImage;

@end
