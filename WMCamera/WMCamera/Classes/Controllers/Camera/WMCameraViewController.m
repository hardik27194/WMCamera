//
//  WMCameraViewController.m
//  WMCamera
//
//  Created by leon on 11/5/15.
//  Copyright © 2015 Codoon. All rights reserved.
//

#import <GPUImage/GPUImage.h>
#import <Masonry/Masonry.h>

#import "WMCameraViewController.h"
#import "WMImageEditViewController.h"

#import "WMNavigationBarView.h"
#import "WMCameraControlView.h"
#import "WMWaterMarkCollectionView.h"
#import "WMCircleMaskView.h"

#import "WMWatermarkProtocol.h"

#import "WMImageUtils.h"
#import "WMUIMacros.h"



@interface WMCameraViewController () <WMCameraControlDelegate, WMWaterMarkSelectionDelegate> {
    @private
    GPUImageStillCamera                                 *_stillCamera;
    GPUImageFilter                                      *_filter;
}

@property (nonatomic, weak) WMNavigationBarView         *navigationBarView;
@property (nonatomic, weak) GPUImageView                *gpuImageView;

@property (nonatomic, strong) WMCameraControlView       *cameraControlView;
@property (nonatomic, strong) WMWaterMarkCollectionView *watermarkCollectionView;

@property (nonatomic, strong) UIButton                  *btnFlash;
@property (nonatomic, strong) UIButton                  *btnPresent;
@property (nonatomic, strong) UIImageView               *watermarkView;;

@property (nonatomic, assign) NSInteger                 selectedWatermarkIndex;
@property (nonatomic, assign) BOOL                      isCapturing;
@property (nonatomic, strong) id<WMWatermarkProtocol>   selectedWatermark;

@end

@implementation WMCameraViewController

#pragma mark - Life Cycle

- (id)init {
    if(self = [super init]) {
        _isCapturing                = NO;
        _selectedWatermarkIndex     = -1;
        _captureDevicePosition      = AVCaptureDevicePositionBack;
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_stillCamera stopCameraCapture];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initCamera];
    [self initSubviews];
    [self refreshFlashMode];
    [self configWatermark];
    [self showGPUImageViewWithFade];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_stillCamera resumeCameraCapture];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_stillCamera pauseCameraCapture];
    [self hideWatermarkCollectionViewAnimated:YES];
}

#pragma mark - Setter

- (void)setCaptureDevicePosition:(AVCaptureDevicePosition)captureDevicePosition {
    if(captureDevicePosition <= AVCaptureDevicePositionUnspecified) {
        return;
    }
    
    _captureDevicePosition = captureDevicePosition;
}

#pragma mark - Getter 

- (WMCameraControlView *)cameraControlView {
    if(!_cameraControlView) {
        _cameraControlView = [WMCameraControlView cameraControlView];
        _cameraControlView.hideWatermark = !self.isSupportWatermarks;
        [_cameraControlView setDelegate:self];
    }
    
    return _cameraControlView;
}

- (WMWaterMarkCollectionView *)watermarkCollectionView {
    if(!_watermarkCollectionView) {
        _watermarkCollectionView            = [WMWaterMarkCollectionView waterMarkCollectionView];
        _watermarkCollectionView.delegate   = self;
        _watermarkCollectionView.watermarks = self.watermarks;
    }
    
    return _watermarkCollectionView;
}

- (UIButton *)btnFlash {
    if(!_btnFlash) {
        _btnFlash = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnFlash addTarget:self
                      action:@selector(flashChangeAction:)
            forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _btnFlash;
}

- (UIButton *)btnPresent {
    if(!_btnPresent) {
        _btnPresent = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnPresent setImage:[UIImage imageNamed:@"btn_present_normal"]
                     forState:UIControlStateNormal];
        [_btnPresent addTarget:self
                        action:@selector(presentChangeAction:)
              forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _btnPresent;
}

- (UIImageView *)watermarkView {
    if(!_watermarkView) {
        _watermarkView                 = [[UIImageView alloc] init];
        _watermarkView.backgroundColor = [UIColor clearColor];
    }
    
    return _watermarkView;
}

#pragma mark - Private

- (void)initCamera {
    NSString *preset = AVCaptureSessionPresetPhoto;
    if(isIPhone4s) {
        preset = AVCaptureSessionPreset640x480;
    }
    _stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:preset
                                                       cameraPosition:_captureDevicePosition];
    _stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    _stillCamera.horizontallyMirrorFrontFacingCamera    = YES;

    _filter = [[GPUImageFilter alloc] init];

    [_stillCamera addTarget:_filter];
    [_stillCamera startCameraCapture];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}

- (void)initSubviews {    
    WMNavigationBarView *navigationBarView = [[WMNavigationBarView alloc] init];
    navigationBarView.backgroundColor = [UIColor colorWithWhite:52.0f / 255.0f
                                                          alpha:isIPhone4s ? 0.6f : 1.0f];
    [navigationBarView setLeftView:({
        UIButton *leftBtn         = [UIButton buttonWithType:UIButtonTypeCustom];
        leftBtn.bounds            = CGRectMake(0.0, 0.0, 60.0, 40.0);
        leftBtn.contentEdgeInsets = UIEdgeInsetsMake(0.0, -30.0, 0.0, 0.0);
        [leftBtn setImage:[UIImage imageNamed:@"btn_close_camera_normal"]
                 forState:UIControlStateNormal];
        [leftBtn setImage:[UIImage imageNamed:@"btn_close_camera_pressed"]
                 forState:UIControlStateHighlighted];
        [leftBtn addTarget:self
                    action:@selector(closeAction:)
          forControlEvents:UIControlEventTouchUpInside];
        leftBtn;
    })];
    
    [navigationBarView setTitleView:({
        UILabel *titleView      = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.textAlignment = NSTextAlignmentCenter;
        titleView.textColor     = [UIColor whiteColor];
        titleView.text          = NSLocalizedString(@"Take a Photo", nil);
        titleView.font          = [UIFont systemFontOfSize:16.0];
        titleView;
    })];
    
    [navigationBarView setRightView:({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 90.0, 40.0)];
        
        [view addSubview:self.btnFlash];
        [view addSubview:self.btnPresent];
        
        [self.btnFlash mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(view).offset(20.0f);
            make.centerY.equalTo(view);
            make.trailing.equalTo(self.btnPresent.mas_leading);
        }];
        
        [self.btnPresent mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(view);
            make.centerY.equalTo(self.btnFlash);
            make.width.and.height.equalTo(self.btnFlash);
        }];
        
        view;
    })];
    
    [self.view addSubview:navigationBarView];
    _navigationBarView = navigationBarView;
    [navigationBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.and.top.equalTo(self.view);
        make.height.mas_equalTo(44.0);
    }];
    
    [self.view insertSubview:({
        GPUImageView *gpuImageView = [[GPUImageView alloc] init];
        [gpuImageView setFillMode:kGPUImageFillModePreserveAspectRatioAndFill];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(handleTapGesture:)];
        [gpuImageView addGestureRecognizer:tap];
        _gpuImageView = gpuImageView;
    }) belowSubview:_navigationBarView];
    
    [_filter addTarget:_gpuImageView];
    
    [_gpuImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.leading.trailing.equalTo(self.view);
        make.height.equalTo(_gpuImageView.mas_width);
        if(isIPhone4s) {
            make.top.equalTo(_navigationBarView.mas_top);
        }
        else {
            make.top.equalTo(_navigationBarView.mas_bottom);
        }
    }];
    
    [UIView animateWithDuration:0.75 animations:^{
        _gpuImageView.alpha = 1.0;
    }];

    [self.view addSubview:self.cameraControlView];
    
    [self.cameraControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.leading.trailing.equalTo(self.view);
        make.top.equalTo(_gpuImageView.mas_bottom);
    }];
    
    if(_maskType == WMMaskType_Circle) {
        [self.view layoutIfNeeded];
        [self.view addSubview:({
            WMCircleMaskView *maskView = [[WMCircleMaskView alloc] initWithFrame:_gpuImageView.frame];
            maskView;
        })];
    }
}

- (void)configWatermark {
    if(self.selectedWatermarkIndex < 0 || self.selectedWatermarkIndex >= self.watermarks.count) {
        return;
    }
    
    _selectedWatermark = self.watermarks[self.selectedWatermarkIndex];
    [self layoutCurrentSelectedWaterMark];
}

- (void)showGPUImageViewWithFade {
    self.gpuImageView.alpha = 0.0;
    [UIView animateWithDuration:0.75 animations:^{
        self.gpuImageView.alpha = 1.0;
    }];
}

- (void)refreshFlashMode {
    switch (_stillCamera.inputCamera.flashMode) {
        case AVCaptureFlashModeOff: {
            [self.btnFlash setImage:[UIImage imageNamed:@"btn_flash_close_normal"]
                           forState:UIControlStateNormal];
            break;
        }
        case AVCaptureFlashModeOn: {
            [self.btnFlash setImage:[UIImage imageNamed:@"btn_flash_open_normal"]
                           forState:UIControlStateNormal];
            break;
        }
        case AVCaptureFlashModeAuto: {
            [self.btnFlash setImage:[UIImage imageNamed:@"btn_flash_auto_normal"]
                           forState:UIControlStateNormal];
            break;
        }
        default:
            break;
    }
}

- (void)showWatermarkCollectionViewAnimated:(BOOL)animated {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGRect frameOnWindow = [self.view convertRect:self.gpuImageView.frame toView:window];
    CGRect toFrame = CGRectMake(0.0,
                                frameOnWindow.origin.y + frameOnWindow.size.height,
                                window.frame.size.width,
                                window.frame.size.height - (frameOnWindow.size.height + frameOnWindow.origin.y));
    CGRect fromFrame = CGRectMake(0.0,
                                  window.frame.size.height,
                                  window.frame.size.width,
                                  window.frame.size.height - frameOnWindow.size.height);
    self.watermarkCollectionView.frame = fromFrame;
    [window addSubview:self.watermarkCollectionView];
    
    void (^ block)(void) = ^{
        self.watermarkCollectionView.frame = toFrame;
    };
    
    if(animated) {
        [UIView animateWithDuration:0.25
                         animations:block];
    }
    else {
        block();
    }
}

- (void)hideWatermarkCollectionViewAnimated:(BOOL)animated {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGRect frameOnWindow = [self.view convertRect:self.gpuImageView.frame toView:window];
    CGRect toFrame = CGRectMake(0.0,
                                window.frame.size.height,
                                window.frame.size.width,
                                window.frame.size.height - frameOnWindow.size.height);
    
    void (^ block)(void) = ^{
        self.watermarkCollectionView.frame = toFrame;
    };
    
    void (^ completionBlock)(BOOL finished) = ^(BOOL finished) {
        [self.watermarkCollectionView removeFromSuperview];
    };
    
    if(animated) {
        [UIView animateWithDuration:0.25
                         animations:block
                         completion:completionBlock];
    }
    else {
        block();
        completionBlock(YES);
    }
}

#pragma mark - Output

- (void)outputImage:(UIImage *)aImage {
    if(![self.navigationController respondsToSelector:@selector(cameraViewController:outputImage:)]) {
        return;
    }
    
    [(id<WMCameraViewControllerOutput>)self.navigationController cameraViewController:self
                                                                          outputImage:aImage];
}

- (void)outputFinalSynthetisedImage:(UIImage *)aImage {
    if(![self.navigationController respondsToSelector:@selector(cameraViewController:outputCropedImage:)]) {
        return;
    }
    
    [(id<WMCameraViewControllerOutput>)self.navigationController cameraViewController:self
                                                                    outputCropedImage:aImage];
}

#pragma mark - Water Mark

- (void)setSelectedWatermark:(id<WMWatermarkProtocol>)selectedWatermark atIndex:(NSUInteger)aIndex {
    _selectedWatermark      = selectedWatermark;
    _selectedWatermarkIndex = aIndex;
    
    [self layoutCurrentSelectedWaterMark];
}

- (void)clearWatermark {
    _selectedWatermark      = nil;
    _selectedWatermarkIndex = -1;
    [self.watermarkView removeFromSuperview];
}

- (void)layoutCurrentSelectedWaterMark {
    CGFloat top     = [_selectedWatermark startTop];
    CGFloat left    = [_selectedWatermark startLeft];
    UIImage *image  = [_selectedWatermark imgWatermark];
    CGRect frame    = CGRectMake(self.gpuImageView.bounds.size.width * left,
                                 self.gpuImageView.bounds.size.height * top,
                                 image.size.width * (self.gpuImageView.bounds.size.width / kDefaultCropPhotoWidth),
                                 image.size.height * (self.gpuImageView.bounds.size.height / kDefaultCropPhotoWidth));
    self.watermarkView.frame = frame;
    self.watermarkView.image = image;
    if(self.watermarkView.superview != self.gpuImageView) {
        [self.gpuImageView addSubview:self.watermarkView];
    }
}

#pragma mark - Actions

- (void)closeAction:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)flashChangeAction:(id)sender {
    
    //TODO: 处理一下
    //FLURRY(@"水印相机_Camera Tab_切换闪光灯");
    AVCaptureFlashMode flashMode = _stillCamera.inputCamera.flashMode;
    flashMode += 1;
    flashMode = flashMode % (AVCaptureFlashModeAuto + 1);
    
    if(![_stillCamera.inputCamera isFlashModeSupported:flashMode]) {
        return;
    }
    
    NSError *error = nil;
    [_stillCamera.inputCamera lockForConfiguration:&error];
    if (error == nil) {
        _stillCamera.inputCamera.flashMode = flashMode;
    }
    [_stillCamera.inputCamera unlockForConfiguration];

    [self refreshFlashMode];
}

- (void)presentChangeAction:(id)sender {
    
    //TODO: 处理一下
    //FLURRY(@"水印相机_Camera Tab_切换前后摄像头");
    [_stillCamera rotateCamera];
    if(_stillCamera.inputCamera.position == AVCaptureDevicePositionFront) {
        self.btnFlash.hidden = YES;
        if([_stillCamera.inputCamera isFlashModeSupported:AVCaptureFlashModeOff]) {
            NSError *error = nil;
            [_stillCamera.inputCamera lockForConfiguration:&error];
            if (error == nil) {
                _stillCamera.inputCamera.flashMode = AVCaptureFlashModeOff;
            }
            [_stillCamera.inputCamera unlockForConfiguration];
        }
    }
    else {
        self.btnFlash.hidden = NO;
    }
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tap {
    [self hideWatermarkCollectionViewAnimated:YES];
}

#pragma mark - Application

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [_stillCamera resumeCameraCapture];
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    [_stillCamera pauseCameraCapture];
}

#pragma mark - WMCameraControlDelegate 

- (void)cameraControlViewDidClickedCaputre:(WMCameraControlView *)cameraControlView {
    
    //TODO: 处理一下
    //FLURRY(@"水印相机_Camera Tab_拍照");
    if(self.isCapturing) {
        return;
    }

    self.isCapturing = YES;
    __weak typeof(self) weakSelf = self;
    [_stillCamera capturePhotoAsImageProcessedUpToFilter:_filter
                                   withCompletionHandler:^(UIImage *processedImage, NSError *error)
     {
         UIImage *fixedOrientationImage    = [WMImageUtils fixOrientationForImage:processedImage];
         UIImageWriteToSavedPhotosAlbum(fixedOrientationImage, nil, nil, NULL);
         [self outputImage:fixedOrientationImage];
         
         UIImage *cropedImage              = [WMImageUtils cropImageAsMaxSquare:fixedOrientationImage];
         UIImage *compressedImage          = [WMImageUtils compressImage:cropedImage
                                                                 maxSize:CGSizeMake(kDefaultCropPhotoWidth,
                                                                                    kDefaultCropPhotoWidth)];
         if(self.isSupportWatermarks) {
             WMImageEditViewController *editVC = [[WMImageEditViewController alloc] initWithImage:compressedImage];
             editVC.watermarks                 = self.watermarks;
             editVC.selectedWatermarkIndex     = self.selectedWatermarkIndex;
             [self.navigationController pushViewController:editVC animated:YES];
         }
         else {
             [self outputFinalSynthetisedImage:compressedImage];
         }
         
         weakSelf.isCapturing              = NO;
     }];
}

- (void)cameraControlViewDidClickedWartermark:(WMCameraControlView *)cameraControlView {
    
    //TODO: 处理一下
    //FLURRY(@"水印相机_Camera Tab_＋水印");
    [self showWatermarkCollectionViewAnimated:YES];
}

#pragma mark - WMWaterMarkSelectionDelegate

- (void)waterMarkCollectionView:(WMWaterMarkCollectionView *)wmCollectionView
           didSelectedWatermark:(id<WMWatermarkProtocol>)watermark
                        atIndex:(NSUInteger)aIndex {
    
    //TODO: 处理一下
    //FLURRY(@"水印相机_Camera Tab_＋水印_选择水印");
    [self setSelectedWatermark:watermark atIndex:aIndex];
    [self hideWatermarkCollectionViewAnimated:YES];
}

- (void)waterMarkCollectionViewDidClearWatermark:(WMWaterMarkCollectionView *)wmCollectionView {
    [self clearWatermark];
    [self hideWatermarkCollectionViewAnimated:YES];
}

@end
