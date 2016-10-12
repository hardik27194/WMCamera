//
//  WMCameraControlView.m
//  Blast
//
//  Created by leon on 8/15/16.
//  Copyright © 2016 codoon. All rights reserved.
//

#import "WMCameraControlView.h"

@interface WMCameraControlView ()
@property (nonatomic, weak) IBOutlet UIButton        *btnWartermark;
@property (nonatomic, weak) IBOutlet UIButton        *btnCapture;

@end

@implementation WMCameraControlView

+ (instancetype)cameraControlView {
    WMCameraControlView *view = [[NSBundle mainBundle] loadNibNamed:@"WMCameraControlView"
                                                              owner:self
                                                            options:nil].firstObject;
    return view;
}

- (void)setHideWatermark:(BOOL)hideWatermark {
    _hideWatermark            = hideWatermark;
    self.btnWartermark.hidden = hideWatermark;
}

#pragma mark - Actions

- (IBAction)captureAction:(id)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(cameraControlViewDidClickedCaputre:)]) {
        [_delegate cameraControlViewDidClickedCaputre:self];
    }
}

- (IBAction)waterMarkAction:(id)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(cameraControlViewDidClickedWartermark:)]) {
        [_delegate cameraControlViewDidClickedWartermark:self];
    }
}
@end
