//
//  WMAbstractViewController.m
//  WMCamera
//
//  Created by leon on 11/13/15.
//  Copyright © 2015 Codoon. All rights reserved.
//

#import "WMAbstractViewController.h"

@interface WMAbstractViewController () <UIGestureRecognizerDelegate>

@end

@implementation WMAbstractViewController

#pragma mark - Life Cycle

- (id)init {
    if(self = [super init]) {
        _statusBarHidden = YES;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:52.0f / 255.0f alpha:1.0f];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if([self.parentViewController isKindOfClass:[UINavigationController class]] &&
       [self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if([self.navigationController isBeingPresented]) {
        _statusBarHidden = YES;
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if([self.parentViewController isKindOfClass:[UINavigationController class]] &&
       [self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]){
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
    
    if([self.navigationController isBeingDismissed]) {
        _statusBarHidden = NO;
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

#pragma mark - Supports

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return _statusBarHidden;
}

- (BOOL)supportBackPopGesture {
    return YES;
}

#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    BOOL bRet = NO;
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        if([self.navigationController.viewControllers count] > 1){
            bRet = YES;
        }
        else{
            bRet = NO;
        }
    }
    return bRet & [self supportBackPopGesture];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return [gestureRecognizer isKindOfClass:UIScreenEdgePanGestureRecognizer.class] & [self supportBackPopGesture];
}

@end
