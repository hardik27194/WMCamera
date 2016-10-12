//
//  ViewController.m
//  WMCamera
//
//  Created by LeoKing on 16/10/11.
//  Copyright © 2016年 LeoKing. All rights reserved.
//

#import "ViewController.h"
#import "WMCamera.h"

@interface ViewController ()<WMCameraDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// 拍照回调
- (void)camera:(nonnull WMCamera *)camera capturedImage:(nullable UIImage *)capturedImage{
    
}

// 相册图片选定回调
- (void)camera:(nonnull WMCamera *)camera cropedImage:(nullable UIImage *)capturedImage{
    
}

// 最终合成图片回调
- (void)camera:(nonnull WMCamera *)camera finalSynthetisedImage:(nullable UIImage *)synthetisedImage{
    
}

- (IBAction)tapCamera:(id)sender {
    WMCamera *camera = [[WMCamera alloc] init];
    camera.maskType = WMMaskType_None;
    camera.wmDelegate = self;
    [self presentViewController:camera animated:YES completion:nil];
}
@end
