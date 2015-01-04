//
//  BezierPathRefreshControl.m
//  BezierPathRefreshControlDemo
//
//  Created by ZhaoYiQi on 14/12/30.
//  Copyright (c) 2014年 ZhaoYiQi. All rights reserved.
//

#import "BezierPathRefreshControl.h"

static const CGFloat kloadingIndividualAnimationTiming = 0.8;
static const CGFloat kbarDarkAlpha = 0.4;
static const CGFloat kloadingTimingOffset = 0.1;
static const CGFloat kdisappearDuration = 1.2;
static const CGFloat krelativeHeightFactor = 2.f/5.f;

typedef enum {
    BezierPathRefreshControlStateIdle = 0,
    BezierPathRefreshControlStateRefreshing = 1,
    BezierPathRefreshControlStateDisappearing = 2
} BezierPathRefreshControlState;

NSString *const startPointKey = @"startPoints";
NSString *const endPointKey = @"endPoints";
NSString *const xKey = @"x";
NSString *const yKey = @"y";

@interface BezierPathBarItem ()

@property (nonatomic) CGPoint middlePoint;
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGPoint endPoint;
@property (nonatomic) UIColor *color;

@end

@implementation BezierPathBarItem

- (instancetype)initWithFrame:(CGRect)frame startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint color:(UIColor *)color lineWidth:(CGFloat)lineWidth
{
    self = [super initWithFrame:frame];
    if (self) {
        _startPoint = startPoint;
        _endPoint = endPoint;
        _lineWidth = lineWidth;
        _color = color;
        
        CGPoint (^middlePoint)(CGPoint, CGPoint) = ^CGPoint(CGPoint a, CGPoint b) {
            CGFloat x = (a.x + b.x)/2.f;
            CGFloat y = (a.y + b.y)/2.f;
            return CGPointMake(x, y);
        };
        _middlePoint = middlePoint(startPoint, endPoint);
    }
    return self;
}

- (void)setupWithFrame:(CGRect)rect
{
    self.layer.anchorPoint = CGPointMake(self.middlePoint.x/self.frame.size.width, self.middlePoint.y/self.frame.size.height);
    self.frame = CGRectMake(self.frame.origin.x + self.middlePoint.x - self.frame.size.width/2, self.frame.origin.y + self.middlePoint.y - self.frame.size.height/2, self.frame.size.width, self.frame.size.height);
}

- (void)setHorizontalRandomness:(int)horizontalRandomness dropHeight:(CGFloat)dropHeight
{
    int randomNumber = - horizontalRandomness + arc4random()%horizontalRandomness*2;
    self.translationX = randomNumber;
    self.transform = CGAffineTransformMakeTranslation(self.translationX, -dropHeight);
}

- (void)drawRect:(CGRect)rect {
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint:self.startPoint];
    [bezierPath addLineToPoint:self.endPoint];
    [self.color setStroke];
    bezierPath.lineWidth = self.lineWidth;
    [bezierPath stroke];
}

@end

@interface BezierPathRefreshControl () <UIScrollViewDelegate>

@property (nonatomic) BezierPathRefreshControlState state;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *barItems;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) id target;
@property (nonatomic) SEL action;

@property (nonatomic) CGFloat dropHeight;
@property (nonatomic) CGFloat originalTopContentInset;
@property (nonatomic) CGFloat disappearProgress;
@property (nonatomic) CGFloat internalAnimationFactor;
@property (nonatomic) int horizontalRandomness;
@property (nonatomic) BOOL reverseLoadingAnimation;

@end

@implementation BezierPathRefreshControl

- (id)initWithTarget:(id)target
       refreshAction:(SEL)refreshAction
               plist:(NSString *)plist{
    return [self initWithTarget:target
                  refreshAction:refreshAction
                          plist:plist
                          color:[UIColor whiteColor]
                      lineWidth:2
                     dropHeight:44
                          scale:1
           horizontalRandomness:150
        reverseLoadingAnimation:NO
        internalAnimationFactor:0.7];
}

- (id)initWithTarget:(id)target
       refreshAction:(SEL)refreshAction
               plist:(NSString *)plist
               color:(UIColor*)color
           lineWidth:(CGFloat)lineWidth
          dropHeight:(CGFloat)dropHeight
               scale:(CGFloat)scale
horizontalRandomness:(CGFloat)horizontalRandomness
reverseLoadingAnimation:(BOOL)reverseLoadingAnimation
internalAnimationFactor:(CGFloat)internalAnimationFactor{
    if (self=[super init]) {
        self.dropHeight = dropHeight;
        self.horizontalRandomness = horizontalRandomness;
        self.target = target;
        self.scrollView=target;
        self.action = refreshAction;
        self.reverseLoadingAnimation = reverseLoadingAnimation;
        self.internalAnimationFactor = internalAnimationFactor;
        
        // Calculate frame according to points max width and height
        CGFloat width = 0;
        CGFloat height = 0;
        NSDictionary *rootDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:plist ofType:@"plist"]];
        NSArray *startPoints = [rootDictionary objectForKey:startPointKey];
        NSArray *endPoints = [rootDictionary objectForKey:endPointKey];
        for (int i=0; i<startPoints.count; i++) {
            
            CGPoint startPoint = CGPointFromString(startPoints[i]);
            CGPoint endPoint = CGPointFromString(endPoints[i]);
            
            if (startPoint.x > width) width = startPoint.x;
            if (endPoint.x > width) width = endPoint.x;
            if (startPoint.y > height) height = startPoint.y;
            if (endPoint.y > height) height = endPoint.y;
        }
        self.frame = CGRectMake(0, -5, width, height);
        
        // Create bar items
        NSMutableArray *mutableBarItems = [[NSMutableArray alloc] init];
        for (int i=0; i<startPoints.count; i++) {
            
            CGPoint startPoint = CGPointFromString(startPoints[i]);
            CGPoint endPoint = CGPointFromString(endPoints[i]);
            
            BezierPathBarItem *barItem = [[BezierPathBarItem alloc] initWithFrame:self.frame startPoint:startPoint endPoint:endPoint color:color lineWidth:lineWidth];
            barItem.tag = i;
            barItem.backgroundColor=[UIColor clearColor];
            barItem.alpha = 0;
            [mutableBarItems addObject:barItem];
            [self addSubview:barItem];
            
            [barItem setHorizontalRandomness:self.horizontalRandomness dropHeight:self.dropHeight];
        }
        
        self.barItems = [NSArray arrayWithArray:mutableBarItems];
        self.frame = CGRectMake(0, 0, width, height);
        self.center = CGPointMake(_scrollView.bounds.size.width/2, 0);
        for (BezierPathBarItem *barItem in self.barItems) {
            [barItem setupWithFrame:self.frame];
        }
        
        self.transform = CGAffineTransformMakeScale(scale, scale);
    }
    return self;
}


#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll
{
    if (self.originalTopContentInset == 0) self.originalTopContentInset = self.scrollView.contentInset.top;
    self.center = CGPointMake(_scrollView.bounds.size.width/2, self.realContentOffsetY*krelativeHeightFactor);
    if (self.state == BezierPathRefreshControlStateIdle)
        [self updateBarItemsWithProgress:self.animationProgress];
}

- (void)scrollViewDidEndDragging
{
    if (self.state == BezierPathRefreshControlStateIdle && self.realContentOffsetY < -self.dropHeight) {

        if (self.animationProgress == 1) self.state = BezierPathRefreshControlStateRefreshing;
        
        if (self.state == BezierPathRefreshControlStateRefreshing) {
            
            UIEdgeInsets newInsets = self.scrollView.contentInset;
            newInsets.top = 10+self.dropHeight;
            CGPoint contentOffset = self.scrollView.contentOffset;

            [UIView animateWithDuration:0 animations:^(void) {
                self.scrollView.contentInset = newInsets;
                self.scrollView.contentOffset = contentOffset;
            }];
            
            if (_delegate!=nil&&[_delegate respondsToSelector:@selector(refreshBezierPath)]) {
                [_delegate refreshBezierPath];
            }
            else{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                
                if ([self.target respondsToSelector:self.action])
                    [self.target performSelector:self.action withObject:self];
                
#pragma clang diagnostic pop

            }
            
            [self startLoadingAnimation];
        }
    }
    
}

#pragma mark Private Methods

- (CGFloat)animationProgress
{
    return MIN(1.f, MAX(0, fabsf(self.realContentOffsetY)/self.dropHeight));
}

- (CGFloat)realContentOffsetY
{
    return self.scrollView.contentOffset.y;
}

- (void)updateBarItemsWithProgress:(CGFloat)progress
{
    for (BezierPathBarItem *barItem in self.barItems) {
        NSInteger index = [self.barItems indexOfObject:barItem];
        CGFloat startPadding = (1 - self.internalAnimationFactor) / self.barItems.count * index;
        CGFloat endPadding = 1 - self.internalAnimationFactor - startPadding;
        
        if (progress == 1 || progress >= 1 - endPadding) {
            barItem.transform = CGAffineTransformIdentity;
            barItem.alpha = kbarDarkAlpha;
        }
        else if (progress == 0) {
            [barItem setHorizontalRandomness:self.horizontalRandomness dropHeight:self.dropHeight];
        }
        else {
            CGFloat realProgress;
            if (progress <= startPadding)
                realProgress = 0;
            else
                realProgress = MIN(1, (progress - startPadding)/self.internalAnimationFactor);
            barItem.transform = CGAffineTransformMakeTranslation(barItem.translationX*(1-realProgress), -self.dropHeight*(1-realProgress));
            barItem.transform = CGAffineTransformRotate(barItem.transform, M_PI*(realProgress));
            barItem.transform = CGAffineTransformScale(barItem.transform, realProgress, realProgress);
            barItem.alpha = realProgress * kbarDarkAlpha;
        }
    }
}

- (void)startLoadingAnimation
{
    if (self.reverseLoadingAnimation) {
        int count = (int)self.barItems.count;
        for (int i= count-1; i>=0; i--) {
            BezierPathBarItem *barItem = [self.barItems objectAtIndex:i];
            [self performSelector:@selector(barItemAnimation:) withObject:barItem afterDelay:(self.barItems.count-i-1)*kloadingTimingOffset inModes:@[NSRunLoopCommonModes]];
        }
    }
    else {
        for (int i=0; i<self.barItems.count; i++) {
            BezierPathBarItem *barItem = [self.barItems objectAtIndex:i];
            [self performSelector:@selector(barItemAnimation:) withObject:barItem afterDelay:i*kloadingTimingOffset inModes:@[NSRunLoopCommonModes]];
        }
    }
}

- (void)barItemAnimation:(BezierPathBarItem*)barItem
{
    if (self.state == BezierPathRefreshControlStateRefreshing) {
        barItem.alpha = 1;
        [barItem.layer removeAllAnimations];
        [UIView animateWithDuration:kloadingIndividualAnimationTiming animations:^{
            barItem.alpha = kbarDarkAlpha;
        } completion:^(BOOL finished) {
            
        }];
        
        BOOL isLastOne;
        if (self.reverseLoadingAnimation)
            isLastOne = barItem.tag == 0;
        else
            isLastOne = barItem.tag == self.barItems.count-1;
            
        if (isLastOne && self.state == BezierPathRefreshControlStateRefreshing) {
            [self startLoadingAnimation];
        }
    }
}

- (void)updateDisappearAnimation
{
    if (self.disappearProgress >= 0 && self.disappearProgress <= 1) {
        self.disappearProgress -= 1/60.f/kdisappearDuration;
        //60.f means this method get called 60 times per second
        [self updateBarItemsWithProgress:self.disappearProgress];
    }
}

#pragma mark Public Methods

- (void)finishingLoading
{
    self.state = BezierPathRefreshControlStateDisappearing;
    UIEdgeInsets newInsets = self.scrollView.contentInset;
    newInsets.top = 0;
    [UIView animateWithDuration:kdisappearDuration animations:^(void) {
        self.scrollView.contentInset = newInsets;
    } completion:^(BOOL finished) {
        self.state = BezierPathRefreshControlStateIdle;
        [self.displayLink invalidate];
        self.disappearProgress = 1;
    }];

    for (BezierPathBarItem *barItem in self.barItems) {
        [barItem.layer removeAllAnimations];
        barItem.alpha = kbarDarkAlpha;
    }
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateDisappearAnimation)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    self.disappearProgress = 1;
}

@end
