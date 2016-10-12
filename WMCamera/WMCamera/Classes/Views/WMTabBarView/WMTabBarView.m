//
//  WMTabBarView.m
//  Blast
//
//  Created by leon on 8/12/16.
//  Copyright © 2016 codoon. All rights reserved.
//

#import "WMTabBarView.h"

@interface WMTabBarView ()
@property (nonatomic, strong) UIView            *vLine;

@end

@implementation WMTabBarView


#pragma mark - Private

- (void)setSelectedTabIndex:(NSUInteger)selectedTabIndex {
    BOOL shouldSelect = YES;
    if(_delegate && [_delegate respondsToSelector:@selector(shouldTabBarView:selectedTabIndex:)]) {
        shouldSelect = [_delegate shouldTabBarView:self selectedTabIndex:selectedTabIndex];
    }
    
    if(!shouldSelect) {
        return;
    }
    
    [self layoutIfNeeded];
    if(_delegate && [_delegate respondsToSelector:@selector(tabBarView:willSelectTabIndex:)]) {
        [_delegate tabBarView:self willSelectTabIndex:selectedTabIndex];
    }
    
    CGRect toFrame = CGRectMake(self.frame.size.width / 2 * selectedTabIndex,
                                self.frame.size.height - 1.0,
                                self.frame.size.width / 2, 1.0);
    
    if(!self.vLine.superview) {
        self.vLine.frame = toFrame;
        [self addSubview:self.vLine];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.vLine.frame = toFrame;
    } completion:^(BOOL finished) {
        _selectedTabIndex = selectedTabIndex;
        if(_delegate && [_delegate respondsToSelector:@selector(tabBarView:didSelectTabIndex:)]) {
            [_delegate tabBarView:self didSelectTabIndex:selectedTabIndex];
        }
    }];
}

#pragma mark - Getter

- (UIView *)vLine {
    if(!_vLine) {
        _vLine = [[UIView alloc] init];
        _vLine.backgroundColor = [UIColor colorWithRed:255.0f / 255.0f
                                                 green:94.0f / 255.0f
                                                  blue:0.0
                                                 alpha:2.5f];;
    }
    
    return _vLine;
}

#pragma mark - Actions

- (IBAction)buttonAction:(UIButton *)sender {
    [self setSelectedTabIndex:sender.tag];
}

@end
