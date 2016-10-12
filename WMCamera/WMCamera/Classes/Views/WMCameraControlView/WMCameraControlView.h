//
//  WMCameraControlView.h
//  Blast
//
//  Created by leon on 8/15/16.
//  Copyright © 2016 codoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol WMCameraControlDelegate;
@interface WMCameraControlView : UIView
@property (nonatomic, weak) id<WMCameraControlDelegate>     delegate;
@property (nonatomic, assign) BOOL                          hideWatermark;

+ (instancetype)cameraControlView;

@end


@protocol WMCameraControlDelegate <NSObject>
@optional

- (void)cameraControlViewDidClickedCaputre:(WMCameraControlView *)cameraControlView;
- (void)cameraControlViewDidClickedWartermark:(WMCameraControlView *)cameraControlView;

@end
