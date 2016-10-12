//
//  ALAsset+Utils.m
//  WMCamera
//
//  Created by leon on 11/24/15.
//  Copyright © 2015 Codoon. All rights reserved.
//

#import <ImageIO/ImageIO.h>
#import "ALAsset+Utils.h"
#import "WMImageUtils.h"

// Helper methods for thumbnailForAsset:maxPixelSize:
static size_t getAssetBytesCallback(void *info, void *buffer, off_t position, size_t count) {
    ALAssetRepresentation *rep = (__bridge id)info;
    
    NSError *error = nil;
    size_t countRead = [rep getBytes:(uint8_t *)buffer fromOffset:position length:count error:&error];
    
    if (countRead == 0 && error) {
        // We have no way of passing this info back to the caller, so we log it, at least.
        NSLog(@"thumbnailForAsset:maxPixelSize: got an error reading an asset: %@", error);
    }
    
    return countRead;
}

static void releaseAssetCallback(void *info) {
    // The info here is an ALAssetRepresentation which we CFRetain in thumbnailForAsset:maxPixelSize:.
    // This release balances that retain.
    
    if(info == NULL) {
        return;
    }
    
    CFRelease(info);
}

@implementation ALAsset (Utils)

// Returns a UIImage for the given asset, with size length at most the passed size.
// The resulting UIImage will be already rotated to UIImageOrientationUp, so its CGImageRef
// can be used directly without additional rotation handling.
// This is done synchronously, so you should call this method on a background queue/thread.
- (UIImage *)thumbnailAsMaxPixelSize:(NSUInteger)size {
    NSParameterAssert(size > 0);
    
    ALAssetRepresentation *rep = [self defaultRepresentation];
    
    CGDataProviderDirectCallbacks callbacks = {
        .version = 0,
        .getBytePointer = NULL,
        .releaseBytePointer = NULL,
        .getBytesAtPosition = getAssetBytesCallback,
        .releaseInfo = releaseAssetCallback,
    };
    
    CGDataProviderRef provider = CGDataProviderCreateDirect((void *)CFBridgingRetain(rep), [rep size], &callbacks);
    CGImageSourceRef source = CGImageSourceCreateWithDataProvider(provider, NULL);
    CFDictionaryRef options = (__bridge CFDictionaryRef) @{
                                                           (NSString *)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                                                           (NSString *)kCGImageSourceThumbnailMaxPixelSize : @(size),
                                                           (NSString *)kCGImageSourceCreateThumbnailWithTransform : @YES,
                                                           };
    CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(source, 0, options);
    CFRelease(source);
    CFRelease(provider);
    
    if (!imageRef) {
        return nil;
    }
    
    UIImage *toReturn = [UIImage imageWithCGImage:imageRef];
    
    CFRelease(imageRef);
    
    return toReturn;
}

- (UIImage *)thumbnailImage {
    UIImage *image = [[UIImage alloc] initWithCGImage:self.aspectRatioThumbnail];
    return image;
}

- (UIImage *)fullResolutionImage {
    UIImage *image = [[UIImage alloc] initWithCGImage:[self defaultRepresentation].fullResolutionImage
                                                scale:[self defaultRepresentation].scale
                                          orientation:(UIImageOrientation)[self defaultRepresentation].orientation];
    return image;
}

- (UIImage *)fullScreenImage {
    UIImage *image = [[UIImage alloc] initWithCGImage:[self defaultRepresentation].fullScreenImage
                                                scale:[self defaultRepresentation].scale
                                          orientation:UIImageOrientationUp];
    return image;
}

@end
