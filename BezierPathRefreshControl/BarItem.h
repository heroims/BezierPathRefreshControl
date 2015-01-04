//
//  BarItem.h
//  BezierPathRefreshControlDemo
//
//  Created by ZhaoYiQi on 14/12/30.
//  Copyright (c) 2014年 ZhaoYiQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BarItem : UIView

@property (nonatomic) CGFloat translationX;

- (instancetype)initWithFrame:(CGRect)frame startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint color:(UIColor *)color lineWidth:(CGFloat)lineWidth;
- (void)setupWithFrame:(CGRect)rect;
- (void)setHorizontalRandomness:(int)horizontalRandomness dropHeight:(CGFloat)dropHeight;

@end
