//
//  WMAlbumUtils.m
//  Blast
//
//  Created by leon on 8/18/16.
//  Copyright © 2016 codoon. All rights reserved.
//

#import "WMAlbumUtils.h"

@implementation WMAlbumUtils

+ (ALAssetsLibrary *)assetsLibrary {
    static ALAssetsLibrary *assetsLibrary;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        assetsLibrary = [[ALAssetsLibrary alloc] init];
    });
    
    return assetsLibrary;
}


+ (void)fetchGroups:(ALAssetsGroupType)types
         completion:(nullable void (^)(NSArray * _Nullable groups,NSError * _Nullable error))completion {
    NSMutableArray *allGroups = [NSMutableArray array];
    [[self assetsLibrary] enumerateGroupsWithTypes:types
                                        usingBlock:
     ^(ALAssetsGroup *group, BOOL *stop){
         if(!group) {
             if(completion) {
                 completion (allGroups, nil);
             }
             
             *stop = YES;
         }
         else {
             [allGroups addObject:group];
         }
     } failureBlock:^(NSError *error){
         if(completion) {
             completion(nil, error);
         }
     }];
}

@end
