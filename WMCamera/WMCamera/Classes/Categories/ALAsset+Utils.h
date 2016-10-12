//
//  ALAsset+Utils.h
//  WMCamera
//
//  Created by leon on 11/24/15.
//  Copyright © 2015 Codoon. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>

@interface ALAsset (Utils)

- (UIImage *)thumbnailAsMaxPixelSize:(NSUInteger)size;

- (UIImage *)thumbnailImage;

- (UIImage *)fullResolutionImage;

- (UIImage *)fullScreenImage;

@end
