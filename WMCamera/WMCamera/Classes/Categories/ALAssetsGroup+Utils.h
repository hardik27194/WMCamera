//
//  ALAssetsGroup+Utils.h
//  WMCamera
//
//  Created by leon on 11/24/15.
//  Copyright © 2015 Codoon. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAssetsGroup (Utils)

- (void)fecthLastestAsset:(void (^)(ALAsset *asset))completion;

@end
