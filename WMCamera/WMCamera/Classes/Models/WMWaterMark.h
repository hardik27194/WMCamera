//
//  WMWaterMark.h
//  WMCamera
//
//  Created by leon@dev on 15/11/19.
//  Copyright © 2015年 Codoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WMWatermarkProtocol.h"

@interface WMWaterMark : NSObject <WMWatermarkProtocol>

// The water mark preview image.
@property (nonatomic, strong) UIImage       *previewImage;
// The water mark image.
@property (nonatomic, strong) UIImage       *watermarkImage;

@property (nonatomic, assign) CGFloat       left;

@property (nonatomic, assign) CGFloat       top;

+ (NSArray *)defaultWatermarks;

@end
