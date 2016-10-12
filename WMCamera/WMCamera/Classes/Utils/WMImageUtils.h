//
//  WMImageUtils.h
//  WMCamera
//
//  Created by leon on 11/12/15.
//  Copyright © 2015 Codoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WMImageUtils : NSObject

+ (UIImage *)cropImageAsMaxSquare:(UIImage *)aImage;

+ (UIImage *)cropImage:(UIImage *)aImage usingCropRect:(CGRect)cropRect;

+ (CGSize)compressSize:(CGSize)size maxSize:(CGSize)maxSize;

+ (UIImage *)compressImage:(UIImage *)aImage maxSize:(CGSize)maxSize;

+ (UIImage *)transparentImageSize:(CGSize)size;

+ (UIImage *)addImage:(UIImage *)aImage overlay:(UIImage *)overlay atPoint:(CGPoint)point;

+ (UIImage *)addImage:(UIImage *)aImage overlay:(UIImage *)overlay inRect:(CGRect)rect;

+ (UIImage *)captureLayer:(CALayer *)layer;

+ (UIImage *)compressImageData:(NSData *)imageData maxPixelSize:(CGFloat)maxPixelSize;

+ (UIImage *)fixOrientationForImage:(UIImage *)aImage;

@end
