//
//  WMImageCropView.m
//  WMImageCroper
//
//  Created by leon on 8/5/16.
//  Copyright © 2016 codoon. All rights reserved.
//

#import "WMImageCropView.h"
#import "WMImageUtils.h"
#import "WMUIMacros.h"

@interface WMImageCropView () <UIScrollViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, weak) UIScrollView            *scrollView;
@property (nonatomic, weak) UIImageView             *imageView;


@end

@implementation WMImageCropView

- (id)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        [self initSubviews];
    }
    
    return self;
}

- (void)initSubviews {
    [self addSubview:({
        CGRect frame                              = self.bounds;
        UIViewAutoresizing autoresizingMask       = UIViewAutoresizingFlexibleTopMargin;
        autoresizingMask                          |= UIViewAutoresizingFlexibleLeftMargin;
        autoresizingMask                          |= UIViewAutoresizingFlexibleRightMargin;
        autoresizingMask                          |= UIViewAutoresizingFlexibleBottomMargin;
        UIScrollView *scrollView                  = [[UIScrollView alloc] initWithFrame:frame];
        scrollView.autoresizingMask               = autoresizingMask;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator   = NO;
        scrollView.delegate                       = self;
        scrollView.backgroundColor                = [UIColor colorWithWhite:52.0f / 255.0f alpha:1.0f];
        scrollView.clipsToBounds                  = YES;
        scrollView.bounces                        = YES;
        scrollView.bouncesZoom                    = NO;
        scrollView.maximumZoomScale               = 3.0f;
        scrollView.minimumZoomScale               = 1.0f;
        

        _scrollView                               = scrollView;
    })];
    
    /*
    [_scrollView addGestureRecognizer:({
        UIRotationGestureRecognizer *rotationGes  = [[UIRotationGestureRecognizer alloc] initWithTarget:self
                                                                                                 action:@selector(handleRotation:)];
        rotationGes.delegate                      = self;
        rotationGes;
    })];
    */
    
    [_scrollView addSubview:({
        UIImageView *imageView              = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView.backgroundColor           = [UIColor clearColor];
        imageView.userInteractionEnabled    = YES;
        imageView.contentMode               = UIViewContentModeScaleAspectFill;
        
        UITapGestureRecognizer *doubleTap   = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(handleDoubleTapGesture:)];
        doubleTap.numberOfTapsRequired      = 2;
        [imageView addGestureRecognizer:doubleTap];
        
        _imageView                          = imageView;
    })];
}

#pragma mark - Actions

- (void)handleDoubleTapGesture:(UITapGestureRecognizer *)tapGesture {
    if(_scrollView.zoomScale <= _scrollView.minimumZoomScale) {
        [_scrollView setZoomScale:_scrollView.maximumZoomScale animated:YES];
    }
    else {
        [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:YES];
    }
}
/*
- (void)handleRotation:(UIRotationGestureRecognizer *)gestureRecognizer {
    CGFloat rotation            = gestureRecognizer.rotation;
    CGAffineTransform transform = CGAffineTransformRotate(_imageView.transform, rotation);
    _imageView.transform        = transform;
    gestureRecognizer.rotation  = 0.0f;
}
*/

#pragma mark - Public

- (void)setImage:(UIImage *)image {
    _image              = image;
    _imageView.image    = image;
}

- (void)relayoutImage {
    if(!_image) {
        return;
    }
    
    [_scrollView setZoomScale:1.0 animated:NO];
    
    CGFloat imgWidth    = _image.size.width;
    CGFloat imgHeight   = _image.size.height;
    CGFloat ratio       = imgHeight > 0.0 ? (imgWidth / imgHeight) : 1.0;
    
    if(imgWidth <= imgHeight) {
        // 宽度填满
        CGSize size      = CGSizeMake(_scrollView.frame.size.width,_scrollView.frame.size.width / ratio);
        _imageView.frame = CGRectMake(0.0, 0.0, size.width, size.height);
        [_scrollView setContentSize:CGSizeMake(size.width, size.height)];
    }
    else {
        // 高度填满
        CGSize size      = CGSizeMake(_scrollView.frame.size.height * ratio, _scrollView.frame.size.height);
        _imageView.frame = CGRectMake(0.0, 0.0, size.width, size.height);
        [_scrollView setContentSize:CGSizeMake(size.width, size.height)];
    }
}

- (UIImage *)currentCropedImage {
    CGFloat width   = (_image.size.width * (_scrollView.frame.size.width / _scrollView.contentSize.width));
    CGFloat x       = (_image.size.width * (_scrollView.contentOffset.x / _scrollView.contentSize.width));
    CGFloat y       = (_image.size.height * (_scrollView.contentOffset.y / _scrollView.contentSize.height));
    
    CGRect cropRect             = CGRectMake(x, y, width, width);
    UIImage *cropedImage        = [WMImageUtils cropImage:_image usingCropRect:cropRect];
    UIImage *compressedImage    = [WMImageUtils compressImage:cropedImage
                                                      maxSize:CGSizeMake(kDefaultCropPhotoWidth, kDefaultCropPhotoWidth)];
    return compressedImage;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
