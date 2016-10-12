//
//  ALAssetsGroup+Utils.m
//  WMCamera
//
//  Created by leon on 11/24/15.
//  Copyright © 2015 Codoon. All rights reserved.
//

#import "ALAssetsGroup+Utils.h"

@implementation ALAssetsGroup (Utils)

- (void)fecthLastestAsset:(void (^)(ALAsset *asset))completion {
    [self setAssetsFilter:[ALAssetsFilter allPhotos]];
    [self enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *asset, NSUInteger idx, BOOL *stop){
        if(completion) {
            completion(asset);
        }
       
       *stop = YES;
    }];
}

@end
