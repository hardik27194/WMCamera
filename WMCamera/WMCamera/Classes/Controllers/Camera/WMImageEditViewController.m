//
//  WMImageEditViewController.m
//  Blast
//
//  Created by leon on 8/15/16.
//  Copyright © 2016 codoon. All rights reserved.
//

#import <Masonry/Masonry.h>
#import <Runtopia-Defines/Runtopia-Defines.h>
#import <Flurry_iOS_SDK/Flurry.h>

#import "WMImageEditViewController.h"

#import "WMNavigationBarView.h"
#import "WMWaterMarkCollectionView.h"

#import "WMWatermarkProtocol.h"

#import "WMImageUtils.h"
#import "WMUIMacros.h"


@interface WMImageEditViewController () <WMWaterMarkSelectionDelegate>
@property (nonatomic, weak) WMNavigationBarView             *navigationBarView;
@property (nonatomic, weak) UIImageView                     *imageView;

@property (nonatomic, strong) WMWaterMarkCollectionView     *watermarkCollectionView;
@property (nonatomic, strong) UIImageView                   *watermarkView;;

@property (nonatomic, strong) id<WMWatermarkProtocol>       selectedWatermark;


@end

@implementation WMImageEditViewController
@synthesize image = _image;

- (id)initWithImage:(UIImage *)aImage {
    if(self = [self init]) {
        _image = aImage;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initSubviews];
    [self configWatermark];
}

- (void)initSubviews {
    WMNavigationBarView *navigationBarView = [[WMNavigationBarView alloc] init];
    navigationBarView.backgroundColor      = [UIColor colorWithWhite:52.0f / 255.0f
                                                               alpha:isIPhone4s ? 0.6f : 1.0f];

    [navigationBarView setLeftView:({
        UIButton *leftBtn         = [UIButton buttonWithType:UIButtonTypeCustom];
        leftBtn.bounds            = CGRectMake(0.0, 0.0, 60.0, 40.0);
        leftBtn.contentEdgeInsets = UIEdgeInsetsMake(0.0, -30.0, 0.0, 0.0);
        
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        UIImage *image = [UIImage imageNamed:@"btn_back_camera_normal" inBundle:bundle compatibleWithTraitCollection:nil];
        [leftBtn setImage:image
                 forState:UIControlStateNormal];
        [leftBtn addTarget:self
                    action:@selector(backAction:)
          forControlEvents:UIControlEventTouchUpInside];
        leftBtn;
    })];
    
    [navigationBarView setTitleView:({
        UILabel *titleView      = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.textColor     = [UIColor whiteColor];
        titleView.textAlignment = NSTextAlignmentCenter;
        titleView.text          = NSLocalizedString(@"Edit", nil);
        titleView.font          = [UIFont systemFontOfSize:16.0];
        titleView;
    })];
    
    [navigationBarView setRightView:({
        UIButton *rightBtn         = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBtn.bounds            = CGRectMake(0.0, 0.0, 60.0, 40.0);
        rightBtn.contentEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, -15.0);
        rightBtn.titleLabel.font   = [UIFont systemFontOfSize:16.0];
        [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        //TODO: 处理一下
        UIColor *firstContentColor = [UIColor colorWithRed:1.0 green:94.f/255.f blue:0 alpha:1.0];
        [rightBtn setTitleColor:firstContentColor forState:UIControlStateHighlighted];
        [rightBtn setTitle:NSLocalizedString(@"Done", nil)
                  forState:UIControlStateNormal];
        [rightBtn addTarget:self
                     action:@selector(doneAction:)
           forControlEvents:UIControlEventTouchUpInside];
        rightBtn;
    })];
    
    [self.view addSubview:navigationBarView];
    _navigationBarView                = navigationBarView;
    [navigationBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.and.top.equalTo(self.view);
        make.height.mas_equalTo(44.0);
    }];
    
    [self.view insertSubview:({
        UIImageView *imageView = [[UIImageView alloc] initWithImage:_image];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView = imageView;
    }) belowSubview:_navigationBarView];
    
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.leading.trailing.equalTo(self.view);
        make.height.equalTo(_imageView.mas_width);
        if(isIPhone4s) {
            make.top.equalTo(_navigationBarView.mas_top);
        }
        else {
            make.top.equalTo(_navigationBarView.mas_bottom);
        }
    }];
    
    [self.view addSubview:self.watermarkCollectionView];
    [self.watermarkCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.top.equalTo(_imageView.mas_bottom);
    }];
}

- (void)configWatermark {
    if(self.selectedWatermarkIndex < 0 || self.selectedWatermarkIndex >= self.watermarks.count) {
        return;
    }
    
    _selectedWatermark = self.watermarks[self.selectedWatermarkIndex];
    
    [self.view layoutIfNeeded];
    self.watermarkCollectionView.selectedIndex = self.selectedWatermarkIndex;
    [self layoutCurrentSelectedWaterMark];
}

#pragma mark - Getter

- (WMWaterMarkCollectionView *)watermarkCollectionView {
    if(!_watermarkCollectionView) {
        _watermarkCollectionView            = [WMWaterMarkCollectionView waterMarkCollectionView];
        _watermarkCollectionView.delegate   = self;
        _watermarkCollectionView.watermarks = self.watermarks;
    }
    
    return _watermarkCollectionView;
}

- (UIImageView *)watermarkView {
    if(!_watermarkView) {
        _watermarkView                 = [[UIImageView alloc] init];
        _watermarkView.backgroundColor = [UIColor clearColor];
    }
    
    return _watermarkView;
}

#pragma mark - Output

- (void)outputImage:(UIImage *)aImage {
    if(![self.navigationController respondsToSelector:@selector(imageEditViewController:outputImage:)]) {
        return;
    }
    
    [(id<WMImageEditViewControllerOutput>)self.navigationController imageEditViewController:self
                                                                                outputImage:aImage];
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
    if(!_selectedWatermark) {
        return;
    }
    
    UIImage *image  = [_selectedWatermark imgWatermark];
    if(!image) {
        return;
    }
    
    CGFloat top     = [_selectedWatermark startTop];
    CGFloat left    = [_selectedWatermark startLeft];
    CGFloat width   = image.size.width * (self.imageView.bounds.size.width / kDefaultCropPhotoWidth);
    CGFloat height  = image.size.height * (self.imageView.bounds.size.height / kDefaultCropPhotoWidth);

    CGRect frame    = CGRectMake(self.imageView.bounds.size.width * left,
                                 self.imageView.bounds.size.height * top,
                                 width,
                                 height);
    self.watermarkView.frame = frame;
    self.watermarkView.image = image;
    if(self.watermarkView.superview != self.imageView) {
        [self.imageView addSubview:self.watermarkView];
    }
}

#pragma mark - Actions

- (void)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneAction:(id)sender {
    FLURRY(@"水印相机_Edit_Done");
    if(!_image) {
        return;
    }
    
    UIImage *synthetisedImage   = _image;
    UIImage *imgWatermark       = [_selectedWatermark imgWatermark];
    if(imgWatermark) {
        CGFloat top     = [_selectedWatermark startTop];
        CGFloat left    = [_selectedWatermark startLeft];
        CGFloat width   = imgWatermark.size.width * (_image.size.width / kDefaultCropPhotoWidth);
        CGFloat height  = imgWatermark.size.height * (_image.size.height / kDefaultCropPhotoWidth);
        CGRect frame    = CGRectMake(_image.size.width * left,
                                     _image.size.height * top,
                                     width,
                                     height);
        synthetisedImage = [WMImageUtils addImage:_image
                                          overlay:imgWatermark
                                           inRect:frame];
    }
    
    [self outputImage:synthetisedImage];
}

#pragma mark - WMWaterMarkSelectionDelegate

- (void)waterMarkCollectionView:(WMWaterMarkCollectionView *)wmCollectionView
           didSelectedWatermark:(id<WMWatermarkProtocol>)watermark
                        atIndex:(NSUInteger)aIndex {
    FLURRY(@"水印相机_Edit_选择水印");
    [self setSelectedWatermark:watermark atIndex:aIndex];
}

- (void)waterMarkCollectionViewDidClearWatermark:(WMWaterMarkCollectionView *)wmCollectionView {
    [self clearWatermark];
}

@end
