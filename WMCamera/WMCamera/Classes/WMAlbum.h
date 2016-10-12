//
//  WMAlbum.h
//  Blast
//
//  Created by leon on 8/18/16.
//  Copyright © 2016 codoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WMAlbumDelegate;
@interface WMAlbum : UINavigationController
@property (nonatomic, weak, readwrite)  id<WMAlbumDelegate>         _Nullable   wmDelegate;
// Default is 1.
@property (nonatomic, assign, readwrite) NSUInteger                             allowsMultipleSelectionCount;

// Default is Done
@property (nonatomic, copy, readwrite) NSString                     * _Nullable rightTitle;


@end


@protocol WMAlbumDelegate <NSObject>
@optional

- (void)album:(nonnull WMAlbum *)album didSelectImage:(nullable UIImage *)image;

/**
 *  @author leon, 16-08-18 17:07:29
 *
 *  Invoked when the camera selected images.
 *
 *  @param camera The camera object
 *  @param images The selected images
 */
- (void)album:(nonnull WMAlbum *)album didSelectImages:(nullable NSArray *)images;

/**
 *  @author leon, 16-08-18 15:26:29
 *
 *  Invoked when the count of selected images exceeds allows selection count .
 *
 *  @param camera The camera object
 *  @param image The exceed image
 */
- (void)album:(nonnull WMAlbum *)album willExceedAllowsSelectionCountWithImage:(nullable UIImage *)image;

@end
