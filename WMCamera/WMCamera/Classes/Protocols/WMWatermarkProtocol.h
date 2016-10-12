//
//  WMWatermarkProtocol.h
//  Blast
//
//  Created by leon on 8/16/16.
//  Copyright © 2016 codoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol WMWatermarkProtocol <NSObject>
@required

// 水印内容图片
- (UIImage *)imgWatermark;

// 水印预览图片
- (UIImage *)imgPreview;

// 水印上边距到原图上边距的距离百分比
- (CGFloat)startTop;

// 水印左边距到原图左边距的距离百分比
- (CGFloat)startLeft;

@end
