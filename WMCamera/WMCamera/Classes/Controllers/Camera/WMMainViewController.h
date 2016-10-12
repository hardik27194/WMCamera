//
//  WMMainViewController.h
//  WMImageCroper
//
//  Created by leon on 8/3/16.
//  Copyright © 2016 codoon. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "WMAbstractViewController.h"
#import "WMWatermarkProtocol.h"
#import "WMTypes.h"

@interface WMMainViewController : WMAbstractViewController
@property (nonatomic, copy, readonly   ) NSArray                 *watermarks;
@property (nonatomic, assign, readwrite) WMMaskType              maskType;
@property (nonatomic, assign, readwrite) AVCaptureDevicePosition captureDevicePosition;

// 带水印，即使watermarks参数为nil也会有默认水印供选择
- (id)initWithWatermarks:(NSArray *)watermarks;

// 不带水印，拍照或者选择相片后立即技术水印相机，不再走水印选择流程
- (id)init;

@end
