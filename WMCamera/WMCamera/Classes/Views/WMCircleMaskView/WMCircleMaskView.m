//
//  WMCircleMaskView.m
//  Blast
//
//  Created by leon on 9/5/16.
//  Copyright © 2016 codoon. All rights reserved.
//

#import "WMCircleMaskView.h"

@implementation WMCircleMaskView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    self.userInteractionEnabled = NO;
    float width                 = MIN(self.frame.size.width, self.frame.size.height);
    float x                     = (self.frame.size.width - width) / 2;
    float y                     = (self.frame.size.height - width) / 2;

    UIBezierPath *circlePath    = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0.0, 0.0, width, width)];
    UIBezierPath *rectPath      = [UIBezierPath bezierPathWithRect:CGRectMake(0.0, 0.0, width, width)];
    [rectPath appendPath:circlePath];
    
    CAShapeLayer *maskLayer     = [CAShapeLayer layer];
    maskLayer.path              = rectPath.CGPath;
    maskLayer.fillRule          = kCAFillRuleEvenOdd;
    maskLayer.frame             = CGRectMake(x, y, width, width);
    maskLayer.fillColor         = [[UIColor blackColor] colorWithAlphaComponent:0.6].CGColor;
    maskLayer.lineWidth         = 0;
    [self.layer addSublayer:maskLayer];
}

@end
