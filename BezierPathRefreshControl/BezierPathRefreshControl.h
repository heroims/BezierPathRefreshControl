//
//  BezierPathRefreshControl.h
//  BezierPathRefreshControlDemo
//
//  Created by ZhaoYiQi on 14/12/30.
//  Copyright (c) 2014年 ZhaoYiQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BezierPathBarItem : UIView

@property (nonatomic) CGFloat translationX;

- (instancetype)initWithFrame:(CGRect)frame startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint color:(UIColor *)color lineWidth:(CGFloat)lineWidth;
- (void)setupWithFrame:(CGRect)rect;
- (void)setHorizontalRandomness:(int)horizontalRandomness dropHeight:(CGFloat)dropHeight;

@end

@protocol BezierPathRefreshControlDelegate <NSObject>

-(void)refreshBezierPath;

@end

@interface BezierPathRefreshControl : UIView

@property(nonatomic,strong)id<BezierPathRefreshControlDelegate> delegate;

- (id)initWithTarget:(id)target
       refreshAction:(SEL)refreshAction
               plist:(NSString *)plist;

- (id)initWithTarget:(id)target
       refreshAction:(SEL)refreshAction
               plist:(NSString *)plist
               color:(UIColor*)color
           lineWidth:(CGFloat)lineWidth
          dropHeight:(CGFloat)dropHeight
               scale:(CGFloat)scale
horizontalRandomness:(CGFloat)horizontalRandomness
reverseLoadingAnimation:(BOOL)reverseLoadingAnimation
internalAnimationFactor:(CGFloat)internalAnimationFactor;

- (void)scrollViewDidScroll;

- (void)scrollViewDidEndDragging;

- (void)finishingLoading;

@end
