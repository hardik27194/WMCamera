//
//  WMAlbumsController.h
//  WMCamera
//
//  Created by leon on 11/23/15.
//  Copyright © 2015 Codoon. All rights reserved.
//

#import "WMAbstractViewController.h"

@class ALAssetsGroup;
@protocol WMAlbumsControllerDelegate;

@interface WMAlbumsController : WMAbstractViewController
@property (nonatomic, weak) id<WMAlbumsControllerDelegate>      delegate;
@property (nonatomic, strong) NSArray<ALAssetsGroup *>          *albums;

@end


@protocol WMAlbumsControllerDelegate <NSObject>
@optional

- (void)albumsController:(WMAlbumsController *)albumController didSelectedIndexPath:(NSIndexPath *)indexPath;

@end
