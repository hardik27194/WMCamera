//
//  WMPhotosController.h
//  WMCamera
//
//  Created by leon on 11/6/15.
//  Copyright © 2015 Codoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMAbstractViewController.h"

@protocol WMPhotosControllerDelegate;
@interface WMPhotosController : WMAbstractViewController
@property (nonatomic, weak) id<WMPhotosControllerDelegate>                      _Nullable   delegate;
// Default is 1.
@property (nonatomic, assign, readwrite) NSUInteger                                         allowsMultipleSelectionCount;
// Default is Done
@property (nonatomic, copy, readwrite) NSString                                 * _Nullable rightTitle;

@end


@protocol WMPhotosControllerDelegate <NSObject>
@optional
- (void)photosController:(nonnull WMPhotosController *)photosController didSelectImage:(nullable UIImage *)image;

- (void)photosController:(nonnull WMPhotosController *)photosController didSelectImages:(nullable NSArray *)images;

- (void)photosController:(nonnull WMPhotosController *)photosController willExceedAllowsSelectionCountWithImage:(nullable UIImage *)image;

@end
