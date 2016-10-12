//
//  WMAlbumCell.m
//  WMCamera
//
//  Created by leon on 11/23/15.
//  Copyright © 2015 Codoon. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "WMAlbumCell.h"

@interface WMAlbumCell()
{
    @private
    IBOutlet UIImageView            *_posterView;
    IBOutlet UILabel                *_lblName;
    IBOutlet UILabel                *_lblCount;
}

@end

@implementation WMAlbumCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)configWithAssetGroup:(ALAssetsGroup *)assetGroup {
    [_posterView setImage:[UIImage imageWithCGImage:[assetGroup posterImage]]];
    [_lblName setText:[assetGroup valueForProperty:ALAssetsGroupPropertyName]];
    [_lblCount setText:@(assetGroup.numberOfAssets).stringValue];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
