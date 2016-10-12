//
//  WMMainViewController.m
//  WMImageCroper
//
//  Created by leon on 8/3/16.
//  Copyright © 2016 codoon. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "WMMainViewController.h"
#import "WMPhotosViewController.h"
#import "WMCameraViewController.h"
#import "WMTabBarView.h"
#import "WMWaterMark.h"
#import <Flurry-iOS-SDK/Flurry.h>
#import <Runtopia-Defines/Runtopia-Defines.h>

@interface WMMainViewController () <WMTabBarViewDelegte>
{
    BOOL                    _isBeingShown;
    BOOL                    _isBeingHidden;
    BOOL                    _isSupportWatermarks;
}

@property (nonatomic, strong) WMPhotosViewController            *photosChildVC;
@property (nonatomic, strong) WMCameraViewController            *cameraChildVC;

@property (nonatomic, weak) WMTabBarView                        *tabBarView;


@end

@implementation WMMainViewController
@synthesize watermarks = _watermarks;

- (id)initWithWatermarks:(NSArray *)watermarks {
    if(self = [self init]) {
        _isSupportWatermarks = YES;
        _watermarks          = watermarks;
    }
    
    return self;
}

- (id)init {
    if(self = [super init]) {
        _isSupportWatermarks = NO;
        _statusBarHidden     = NO;
        _isBeingShown        = NO;
        _isBeingHidden       = NO;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initSubviews];
}

- (void)initSubviews {
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:({
        _tabBarView = [[[NSBundle mainBundle] loadNibNamed:@"WMTabBarView"
                                                     owner:self
                                                   options:nil] lastObject];
        _tabBarView.delegate = self;
        _tabBarView;
    })];
    [_tabBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.and.bottom.equalTo(self.view);
        make.height.mas_equalTo(50.0);
    }];
    [_tabBarView setSelectedTabIndex:0];
}

#pragma mark - Getter

- (WMPhotosViewController *)photosChildVC {
    if(!_photosChildVC) {
        _photosChildVC                   = [[WMPhotosViewController alloc] init];
        _photosChildVC.watermarks        = self.watermarks.count > 0 ? self.watermarks : [WMWaterMark defaultWatermarks];
        _photosChildVC.maskType          = _maskType;
        _photosChildVC.supportWatermarks = _isSupportWatermarks;
    }
    
    return _photosChildVC;
}

- (WMCameraViewController *)cameraChildVC {
    if(!_cameraChildVC) {
        _cameraChildVC                       = [[WMCameraViewController alloc] init];
        _cameraChildVC.watermarks            = self.watermarks.count > 0 ? self.watermarks : [WMWaterMark defaultWatermarks];
        _cameraChildVC.maskType              = _maskType;
        _cameraChildVC.captureDevicePosition = _captureDevicePosition;
        _cameraChildVC.supportWatermarks     = _isSupportWatermarks;
    }
    
    return _cameraChildVC;
}

#pragma mark - Private

- (void)changeContentViewToIndex:(NSUInteger)index animated:(BOOL)animated {
    UIViewController *willShowVC = nil;
    if(index == 0) {
        willShowVC = self.photosChildVC;
    }
    else {
        willShowVC = self.cameraChildVC;
    }

    UIViewController *didShowVC = [self.childViewControllers firstObject];
    if(didShowVC == willShowVC) {
        return;
    }
    
    if(didShowVC) {
        void (^ animations)() = ^{
            didShowVC.view.alpha = 0.0;
        };
        
        void (^ completion)(BOOL finished) = ^(BOOL finished) {
            _isBeingHidden = NO;
            [didShowVC.view removeFromSuperview];
            [didShowVC removeFromParentViewController];
        };
        
        _isBeingHidden = YES;
        [didShowVC willMoveToParentViewController:nil];
        if(animated) {
            [UIView animateWithDuration:0.25 animations:animations completion:completion];
        }
        else {
            animations();
            completion(YES);
        }
    }
    
    [self addChildViewController:willShowVC];
    [self.view insertSubview:willShowVC.view atIndex:0];
    [willShowVC.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.and.top.equalTo(self.view);
        make.bottom.equalTo(_tabBarView.mas_top);
    }];
    
    void (^ animations)() = ^{
        willShowVC.view.alpha = 1.0;
    };
    
    void (^ completion)(BOOL finished) = ^(BOOL finished) {
        _isBeingShown = NO;
        [willShowVC didMoveToParentViewController:self];
    };

    willShowVC.view.alpha   = 0.0;
    _isBeingShown           = YES;
    if(animated) {
        [UIView animateWithDuration:0.25 animations:animations completion:completion];
    }
    else {
        animations();
        completion(YES);
    }
}

#pragma mark - WMTabBarViewDelegte

- (BOOL)shouldTabBarView:(WMTabBarView *)tabBar selectedTabIndex:(NSUInteger)tabIndex {
    return (!_isBeingShown && !_isBeingHidden);
}

- (void)tabBarView:(WMTabBarView *)tabBar willSelectTabIndex:(NSUInteger)tabIndex {
    [self changeContentViewToIndex:tabIndex animated:YES];
    if(tabIndex == 0) {
        FLURRY(@"水印相机_Library Tab");
    }
    else {
        FLURRY(@"水印相机_Camera Tab");
    }
}

@end
