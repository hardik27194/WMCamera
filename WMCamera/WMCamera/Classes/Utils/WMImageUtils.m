//
//  WMImageUtils.m
//  WMCamera
//
//  Created by leon on 11/12/15.
//  Copyright © 2015 Codoon. All rights reserved.
//

#import <ImageIO/ImageIO.h>
#import "WMImageUtils.h"

#define rad(angle) ((angle) / 180.0 * M_PI)

@implementation WMImageUtils

+ (CGAffineTransform)orientationTransformedRectOfImage:(UIImage *)img {
    CGAffineTransform rectTransform;
    switch (img.imageOrientation) {
        case UIImageOrientationLeft:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(90)), 0, -img.size.height);
            break;
        case UIImageOrientationRight:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-90)), -img.size.width, 0);
            break;
        case UIImageOrientationDown:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-180)), -img.size.width, -img.size.height);
            break;
        default:
            rectTransform = CGAffineTransformIdentity;
    };
    
    return CGAffineTransformScale(rectTransform, img.scale, img.scale);
}

+ (UIImage *)cropImageAsMaxSquare:(UIImage *)aImage {
    CGFloat width   = aImage.size.width;
    CGFloat height  = aImage.size.height;
    
    CGRect cropRect = CGRectZero;
    if(width >= height) {
        cropRect = CGRectMake((width - height) / 2, 0.0f, height, height);
    }
    else {
        cropRect = CGRectMake(0.0f, (height - width) / 2, width, width);
    }
    
    return [self cropImage:aImage usingCropRect:cropRect];
}

+ (UIImage *)cropImage:(UIImage *)aImage usingCropRect:(CGRect)cropRect {
    CGAffineTransform rectTransform = [[self class] orientationTransformedRectOfImage:aImage];
    CGRect visibleRect              = CGRectApplyAffineTransform(cropRect, rectTransform);
    CGImageRef imageRef             = CGImageCreateWithImageInRect([aImage CGImage], visibleRect);
    UIImage *cropedImage            = [UIImage imageWithCGImage:imageRef
                                                          scale:aImage.scale
                                                    orientation:aImage.imageOrientation];
    CGImageRelease(imageRef);
        
    return cropedImage;
}

+ (CGSize)compressSize:(CGSize)size maxSize:(CGSize)maxSize {
    CGFloat width       = size.width;
    CGFloat height      = size.height;
    
    CGFloat targetWidth     = maxSize.width;
    CGFloat targetHeight    = maxSize.height;
    
    // should not be compressed.
    if(width <= maxSize.width && height <= maxSize.height) {
        return size;
    }
    
    CGFloat widthRatio = maxSize.width / width;
    widthRatio = widthRatio > 1.0 ? 1.0 : widthRatio;
    CGFloat heightRatio = maxSize.height / height;
    heightRatio = heightRatio > 1.0 ? 1.0 : heightRatio;
    
    if(fabs(widthRatio - 1.0) > fabs(heightRatio - 1.0)) {
        targetHeight = height * widthRatio;
    }
    else {
        targetWidth = width * heightRatio;
    }
    
    if(targetWidth - (long)targetWidth >= 0.5) {
        targetWidth = (long)targetWidth + 1.0;
    }
    else if(targetWidth - (long)targetWidth > 0.0000001) {
        targetWidth = (long)targetWidth + 0.5;
    }
    else {
        
    }
    
    if(targetHeight - (long)targetHeight >= 0.5) {
        targetHeight = (long)targetHeight + 1.0;
    }
    else if(targetHeight - (long)targetHeight > 0.0000001) {
        targetHeight = (long)targetHeight + 0.5;
    }
    else {
        
    }
    
    CGSize targetSize = CGSizeMake(targetWidth, targetHeight);

    return targetSize;
}

+ (UIImage *)compressImage:(UIImage *)aImage maxSize:(CGSize)maxSize {
    if(aImage.size.width <= maxSize.width && aImage.size.height <= maxSize.height) {
        return aImage;
    }

    CGSize targetSize = [[self class] compressSize:aImage.size
                                           maxSize:maxSize];
    targetSize.width     *= aImage.scale;
    targetSize.height    *= aImage.scale;
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.size   = targetSize;
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 thumbnailRect.size.width,
                                                 thumbnailRect.size.height,
                                                 CGImageGetBitsPerComponent(aImage.CGImage),
                                                 0,
                                                 CGImageGetColorSpace(aImage.CGImage),
                                                 CGImageGetBitmapInfo(aImage.CGImage));
    CGContextDrawImage(context, thumbnailRect, aImage.CGImage);
    CGImageRef cgImage   = CGBitmapContextCreateImage(context);
    UIImage *newImage    = [UIImage imageWithCGImage:cgImage scale:aImage.scale orientation:aImage.imageOrientation];
    CGImageRelease(cgImage);
    CGContextRelease(context);

    return newImage;
}

+ (UIImage *)transparentImageSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)addImage:(UIImage *)aImage overlay:(UIImage *)overlay atPoint:(CGPoint)point {
    UIGraphicsBeginImageContext(CGSizeMake(aImage.size.width * aImage.scale,
                                           aImage.size.height * aImage.scale));
    
    CGRect frame = CGRectMake(0.0, 0.0,
                              aImage.size.width * aImage.scale,
                              aImage.size.height * aImage.scale);
    [aImage drawInRect:frame];
    
    CGRect overlayFrame = CGRectMake(point.x * overlay.scale,
                                     point.y * overlay.scale,
                                     overlay.size.width * overlay.scale,
                                     overlay.size.height * overlay.scale);
    [overlay drawInRect:overlayFrame];

    CGImageRef cgImage = CGBitmapContextCreateImage(UIGraphicsGetCurrentContext());
    UIImage *newImage = [UIImage imageWithCGImage:cgImage
                                            scale:aImage.scale
                                      orientation:aImage.imageOrientation];
    
    CGImageRelease(cgImage);
    UIGraphicsEndImageContext();

    return newImage;
}

+ (UIImage *)addImage:(UIImage *)aImage overlay:(UIImage *)overlay inRect:(CGRect)rect {
    CGFloat imgWidth   = aImage.size.width;
    CGFloat imgHeight  = aImage.size.height;
    CGRect frame       = CGRectMake(0.0, 0.0, imgWidth, imgHeight);

    UIGraphicsBeginImageContext(CGSizeMake(imgWidth, imgHeight));
    [aImage drawInRect:frame];
    [overlay drawInRect:rect];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)captureLayer:(CALayer *)layer {
    if(!layer){
        return nil;
    }
    
    CGRect rect = layer.frame;
    CGFloat scale = [[UIScreen mainScreen] scale];

    UIGraphicsBeginImageContextWithOptions(rect.size, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [layer renderInContext:context];
    
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)compressImageData:(NSData *)imageData maxPixelSize:(CGFloat)maxPixelSize {
    if(!imageData) {
        return nil;
    }
    
    CGDataProviderDirectCallbacks callbacks = {
        .version = 0,
        .getBytePointer = NULL,
        .releaseBytePointer = NULL,
        .getBytesAtPosition = getDataBytesCallback,
        .releaseInfo = releaseDataCallback
    };
    CGDataProviderRef provider = CGDataProviderCreateDirect((void *)CFBridgingRetain(imageData),
                                                            [imageData length],
                                                            &callbacks);
    CGImageSourceRef source = CGImageSourceCreateWithDataProvider(provider, NULL);
    if(!source) {
        CFRelease(provider);
        return nil;
    }
    NSDictionary *options = @{
                              (NSString *)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                              (NSString *)kCGImageSourceCreateThumbnailWithTransform : @YES,
                              (NSString *)kCGImageSourceThumbnailMaxPixelSize : @(maxPixelSize),
                              (NSString *)kCGImageSourceShouldCache : @NO
                              };
    CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(source, 0,
                                                              (__bridge CFDictionaryRef)options);
    if(!imageRef) {
        CFRelease(source);
        CFRelease(provider);
        return nil;
    }
    
    UIImage *compressedImage = [UIImage imageWithCGImage:imageRef];
    
    CFRelease(source);
    CFRelease(provider);
    CFRelease(imageRef);
    
    return compressedImage;
}

+ (UIImage *)fixOrientationForImage:(UIImage *)aImage {
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    UIImageOrientation oritation = aImage.imageOrientation;
    switch (oritation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored: {
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        }
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored: {
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
        }
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored: {
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        }
        default:
            break;
    }
    
    switch (oritation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored: {
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        }
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored: {
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        }
        default:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

#pragma mark - Helpers

// Helper methods for compressImageData:maxPixelSize:
static unsigned long getDataBytesCallback(void *info, void *buffer, off_t position, size_t count) {
    NSData *data = (__bridge id)info;
    [data getBytes:buffer range:NSMakeRange((NSUInteger)position, count)];
    return count;
}

static void releaseDataCallback(void *info) {
    if(info) {
        CFRelease(info);
    }
}

@end
