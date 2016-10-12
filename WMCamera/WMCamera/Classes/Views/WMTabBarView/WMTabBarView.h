//
//  WMTabBarView.h
//  Blast
//
//  Created by leon on 8/12/16.
//  Copyright © 2016 codoon. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  @author leon, 16-08-12 10:08:06
 *
 *  暂时写的比较死，有时间了再重构一下这个类
 */
@protocol WMTabBarViewDelegte;
@interface WMTabBarView : UIView
@property (nonatomic, readwrite, weak) id<WMTabBarViewDelegte>       delegate;
@property (nonatomic, readwrite, assign) NSUInteger                  selectedTabIndex;

@end



@protocol WMTabBarViewDelegte <NSObject>
@optional

- (BOOL)shouldTabBarView:(WMTabBarView *)tabBar selectedTabIndex:(NSUInteger)tabIndex;

- (void)tabBarView:(WMTabBarView *)tabBar willSelectTabIndex:(NSUInteger)tabIndex;

- (void)tabBarView:(WMTabBarView *)tabBar didSelectTabIndex:(NSUInteger)tabIndex;

@end
