//
//  WMAbstractViewController.h
//  WMCamera
//
//  Created by leon on 11/13/15.
//  Copyright © 2015 Codoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMAbstractViewController : UIViewController
{
    @protected
    BOOL                _statusBarHidden;
}
//@property (nonatomic, assign) BOOL                              statusBarHidden;

- (BOOL)supportBackPopGesture;

@end
