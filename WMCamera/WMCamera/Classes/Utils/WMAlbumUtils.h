//
//  WMAlbumUtils.h
//  Blast
//
//  Created by leon on 8/18/16.
//  Copyright © 2016 codoon. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

@interface WMAlbumUtils : NSObject

+ (void)fetchGroups:(ALAssetsGroupType)types
         completion:(nullable void (^)(NSArray * _Nullable groups,NSError * _Nullable error))completion;

@end
