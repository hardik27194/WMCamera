//
//  WMAlbumCell.h
//  WMCamera
//
//  Created by leon on 11/23/15.
//  Copyright © 2015 Codoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ALAssetsGroup;

@interface WMAlbumCell : UITableViewCell

- (void)configWithAssetGroup:(ALAssetsGroup *)assetGroup;

@end
