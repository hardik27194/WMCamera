//
//  WMWaterMark.m
//  WMCamera
//
//  Created by leon@dev on 15/11/19.
//  Copyright © 2015年 Codoon. All rights reserved.
//

#import "WMWaterMark.h"
#import "WMUIMacros.h"

@implementation WMWaterMark

+ (NSArray *)defaultWatermarks {
    // 以下这些坐标信息是根据设计图(设计图就是相对1080x1080的母图设计的)取出来的
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    WMWaterMark *waterMark1   = [[WMWaterMark alloc] init];
    waterMark1.previewImage   = [UIImage imageNamed:@"ic_wm_gooutrun" inBundle:bundle compatibleWithTraitCollection:nil];
    waterMark1.watermarkImage = [UIImage imageNamed:@"img_wm_gooutrun" inBundle:bundle compatibleWithTraitCollection:nil];
    waterMark1.top            = 828.0f / kDefaultCropPhotoWidth;
    waterMark1.left           = 350.0f / kDefaultCropPhotoWidth;

    WMWaterMark *waterMark2   = [[WMWaterMark alloc] init];
    waterMark2.previewImage   = [UIImage imageNamed:@"ic_wm_wakeup" inBundle:bundle compatibleWithTraitCollection:nil];
    waterMark2.watermarkImage = [UIImage imageNamed:@"img_wm_wakeup" inBundle:bundle compatibleWithTraitCollection:nil];
    waterMark2.top            = 808.0 / kDefaultCropPhotoWidth;
    waterMark2.left           = 201.0 / kDefaultCropPhotoWidth;

    WMWaterMark *waterMark3   = [[WMWaterMark alloc] init];
    waterMark3.previewImage   = [UIImage imageNamed:@"ic_wm_followme" inBundle:bundle compatibleWithTraitCollection:nil];
    waterMark3.watermarkImage = [UIImage imageNamed:@"img_wm_followme" inBundle:bundle compatibleWithTraitCollection:nil];
    waterMark3.top            = 780.0 / kDefaultCropPhotoWidth;
    waterMark3.left           = 225.0 / kDefaultCropPhotoWidth;

    WMWaterMark *waterMark4   = [[WMWaterMark alloc] init];
    waterMark4.previewImage   = [UIImage imageNamed:@"ic_wm_runyourself" inBundle:bundle compatibleWithTraitCollection:nil];
    waterMark4.watermarkImage = [UIImage imageNamed:@"img_wm_runyourself" inBundle:bundle compatibleWithTraitCollection:nil];
    waterMark4.top            = 692.0 / kDefaultCropPhotoWidth;
    waterMark4.left           = 87.0 / kDefaultCropPhotoWidth;

    return @[waterMark1, waterMark2, waterMark3, waterMark4];
}

#pragma mark - WMWatermarkProtocol

// 水印内容图片
- (UIImage *)imgWatermark {
    return self.watermarkImage;
}

// 水印预览图片
- (UIImage *)imgPreview {
    return self.previewImage;
}

// 水印上边距到原图上边距的距离百分比
- (CGFloat)startTop {
    return self.top;
}

// 水印左边距到原图左边距的距离百分比
- (CGFloat)startLeft {
    return self.left;
}

@end
