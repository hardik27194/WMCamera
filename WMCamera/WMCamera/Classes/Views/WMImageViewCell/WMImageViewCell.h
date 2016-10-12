//
//  WMImageViewCell.h
//  WMCamera
//
//  Created by leon on 11/12/15.
//  Copyright © 2015 Codoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMImageViewCell : UICollectionViewCell
@property (nonatomic, weak) IBOutlet UIImageView        *imageView;
@property (nonatomic, weak) IBOutlet UILabel            *lblName;

@end
