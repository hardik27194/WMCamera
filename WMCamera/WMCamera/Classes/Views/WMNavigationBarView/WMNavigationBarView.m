//
//  WMNavigationBarView.m
//  Blast
//
//  Created by leon on 8/12/16.
//  Copyright © 2016 codoon. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "WMNavigationBarView.h"

@implementation WMNavigationBarView

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    [self layoutViews];
}

- (void)layoutViews {
    if(_leftView) {
        [_leftView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(10);
            make.centerY.equalTo(self);
            make.width.mas_equalTo(_leftView.frame.size.width);
            make.height.mas_equalTo(_leftView.frame.size.height);
        }];
    }
    
    if(_titleView) {
        [_titleView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.mas_greaterThanOrEqualTo(_titleView.frame.size.width);
            make.height.mas_greaterThanOrEqualTo(_titleView.frame.size.height);
            if(_leftView) {
                make.leading.greaterThanOrEqualTo(_leftView.mas_trailing).offset(10.0);
            }
            else {
                make.leading.greaterThanOrEqualTo(self).offset(10.0);
            }
            
            if(_rightView) {
                make.trailing.greaterThanOrEqualTo(_rightView.mas_leading).offset(-10.0);
            }
            else {
                make.trailing.greaterThanOrEqualTo(self).offset(-10.0);
            }
        }];
    }
    
    if(_rightView) {
        [_rightView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self).offset(-10);
            make.centerY.equalTo(self);
            make.width.mas_equalTo(_rightView.frame.size.width);
            make.height.mas_equalTo(_rightView.frame.size.height);
        }];
    }
}

#pragma mark - Setter

- (void)setLeftView:(UIView *)leftView {
    _leftView = leftView;
    [self addSubview:leftView];
}

- (void)setTitleView:(UIView *)titleView {
    _titleView = titleView;
    [self addSubview:titleView];
}

- (void)setRightView:(UIView *)rightView {
    _rightView = rightView;
    [self addSubview:rightView];
}

@end
