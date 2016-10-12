//
//  WMAlbum.m
//  Blast
//
//  Created by leon on 8/18/16.
//  Copyright © 2016 codoon. All rights reserved.
//

#import "WMAlbum.h"
#import "WMPhotosController.h"

@interface WMAlbum () <WMPhotosControllerDelegate>
@property (nonatomic, weak) WMPhotosController  *photosController;

@end

@implementation WMAlbum

- (id)init {
    if(self = [super init]) {
        [self setNavigationBarHidden:YES animated:NO];
        [self pushViewController:({
            WMPhotosController *photosController    = [[WMPhotosController alloc] init];
            photosController.delegate               = self;
            _photosController                       = photosController;
        }) animated:NO];
    }
    
    return self;
}

- (void)setRightTitle:(NSString *)rightTitle {
    _rightTitle                     = [rightTitle copy];
    _photosController.rightTitle    = rightTitle;
}

- (void)setAllowsMultipleSelectionCount:(NSUInteger)allowsMultipleSelectionCount {
    _allowsMultipleSelectionCount                   = allowsMultipleSelectionCount;
    _photosController.allowsMultipleSelectionCount  = allowsMultipleSelectionCount;
}

#pragma mark - WMPhotosControllerDelegate

- (void)photosController:(nonnull WMPhotosController *)photosController didSelectImage:(nullable UIImage *)image {
    if(_wmDelegate && [_wmDelegate respondsToSelector:@selector(album:didSelectImage:)]) {
        [_wmDelegate album:self didSelectImage:image];
    }
}

- (void)photosController:(nonnull WMPhotosController *)photosController didSelectImages:(nullable NSArray *)images {
    if(_wmDelegate && [_wmDelegate respondsToSelector:@selector(album:didSelectImages:)]) {
        [_wmDelegate album:self didSelectImages:images];
    }
}

- (void)photosController:(nonnull WMPhotosController *)photosController willExceedAllowsSelectionCountWithImage:(nullable UIImage *)image {
    if(_wmDelegate && [_wmDelegate respondsToSelector:@selector(album:willExceedAllowsSelectionCountWithImage:)]) {
        [_wmDelegate album:self willExceedAllowsSelectionCountWithImage:image];
    }
}

@end
