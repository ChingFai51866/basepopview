//
//  QDAnimationPopView.m
//  QDYuYin
//
//  Created by mac on 2020/11/18.
//  Copyright © 2020 px. All rights reserved.
//

#import "QDAnimationPopView.h"

// 角度转弧度
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

#define RGBACOLOR(r,g,b,a) \
[UIColor colorWithRed:r/256.f green:g/256.f blue:b/256.f alpha:a]

@interface QDAnimationPopView ()<UIGestureRecognizerDelegate>
/** 内容视图 */
@property (nonatomic, strong) UIView *contentView;
/** 背景层 */
@property (nonatomic, strong) UIView *backgroundView;
/** 自定义视图 */
@property (nonatomic, strong) UIView *customView;
/** 显示时动画弹框样式 */
@property (nonatomic) WKAnimationPopStyle animationPopStyle;
/** 移除时动画弹框样式 */
@property (nonatomic) WKAnimationDismissStyle animationDismissStyle;
/** 显示时背景是否透明，透明度是否为<= 0，默认为NO */
@property (nonatomic) BOOL isTransparent;

@end

@implementation QDAnimationPopView

- (nullable instancetype)initWithCustomView:(UIView *_Nonnull)customView
                                   popStyle:(WKAnimationPopStyle)popStyle
                               dismissStyle:(WKAnimationDismissStyle)dismissStyle
{
    // 检测自定义视图是否存在(check customView is exist)
    if (!customView) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        _isClickBGDismiss = NO;
        _isObserverOrientationChange = NO;
        _popBGAlpha = 0.5f;
        _isTransparent = NO;
        _customView = customView;
        _animationPopStyle = popStyle;
        _animationDismissStyle = dismissStyle;
        _popAnimationDuration = -0.1f;
        _dismissAnimationDuration = -0.1f;
      
        self.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
        
        _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        _backgroundView.backgroundColor = [UIColor blackColor];
        _backgroundView.alpha = 0.0f;
        [self addSubview:_backgroundView];
        
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        _contentView.backgroundColor = [UIColor clearColor];
        [self addSubview:_contentView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBGLayer:)];
        tap.delegate = self;
        [_contentView addGestureRecognizer:tap];
        if (popStyle == WKAnimationPopStyleBottomToTop)
        {
            customView.frame = CGRectMake((SCREENWIDTH - customView.bounds.size.width)/2.0, SCREENHEIGHT, customView.bounds.size.width, customView.bounds.size.height);
        }
        else
        {
            customView.center = _contentView.center;
        }
        [_contentView addSubview:customView];
    }
    return self;
}

- (void)setIsObserverOrientationChange:(BOOL)isObserverOrientationChange
{
    _isObserverOrientationChange = isObserverOrientationChange;
    
    if (_isObserverOrientationChange) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
}

- (void)setPopBGAlpha:(CGFloat)popBGAlpha
{
    _popBGAlpha = (popBGAlpha <= 0.0f) ? 0.0f : ((popBGAlpha > 1.0) ? 1.0 : popBGAlpha);
    _isTransparent = (_popBGAlpha == 0.0f);
}

#pragma mark 点击背景(Click background)
- (void)tapBGLayer:(UITapGestureRecognizer *)tap
{
    if (self.clickBgHandler) {
        self.clickBgHandler();
    }
    if (_isClickBGDismiss) {
        [self dismiss];
    }
}

#pragma mark UIGestureRecognizer Delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint location = [touch locationInView:_contentView];
    location = [_customView.layer convertPoint:location fromLayer:_contentView.layer];
    return ![_customView.layer containsPoint:location];
}


- (void)pop:(BOOL)isAddOnView
{
    if (isAddOnView)
    {
        [[QDAnimationPopView getCurrentController:[UIApplication sharedApplication].delegate.window.rootViewController].view addSubview:self];
    }
    else
    {
        [[UIApplication sharedApplication].delegate.window addSubview:self];
    }
    __weak typeof(self) ws = self;
    NSTimeInterval defaultDuration = [self getPopDefaultDuration:self.animationPopStyle];
    NSTimeInterval duration = (_popAnimationDuration < 0.0f) ? defaultDuration : _popAnimationDuration;
    if (self.animationPopStyle == WKAnimationPopStyleNO) {
        self.alpha = 0.0;
        if (self.isTransparent) {
            self.backgroundView.backgroundColor = [UIColor clearColor];
        } else {
            self.backgroundView.alpha = 0.0;
        }
        [UIView animateWithDuration:duration animations:^{
            ws.alpha = 1.0;
            if (!ws.isTransparent) {
                ws.backgroundView.alpha = ws.popBGAlpha;
            }
        }];
    }
    else if (self.animationPopStyle == WKAnimationPopStyleBottomToTop)
    {
        if (ws.isTransparent) {
            self.backgroundView.backgroundColor = [UIColor clearColor];
        } else {
            self.backgroundView.alpha = 0.0;
            [UIView animateWithDuration:duration * 0.5 animations:^{
                ws.backgroundView.alpha = ws.popBGAlpha;
            }];
        }
        _customView.frame = CGRectMake((SCREENWIDTH - _customView.bounds.size.width)/2.0, SCREENHEIGHT, _customView.bounds.size.width, _customView.bounds.size.height);
        [UIView animateWithDuration:duration animations:^{
            ws.customView.frame = CGRectMake((SCREENWIDTH - ws.customView.bounds.size.width)/2.0, SCREENHEIGHT - ws.customView.bounds.size.height, ws.customView.bounds.size.width, ws.customView.bounds.size.height);
        }];
    }
    else
    {
        if (ws.isTransparent) {
            self.backgroundView.backgroundColor = [UIColor clearColor];
        } else {
            self.backgroundView.alpha = 0.0;
            [UIView animateWithDuration:duration * 0.5 animations:^{
                ws.backgroundView.alpha = ws.popBGAlpha;
            }];
        }
        [self hanlePopAnimationWithDuration:duration];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (ws.popComplete) {
            ws.popComplete();
        }
    });
}

-(void)addOnView:(UIView *)bgView{
    
    if (bgView) {
        
        [bgView addSubview:self];
        __weak typeof(self) ws = self;
        NSTimeInterval defaultDuration = [self getPopDefaultDuration:self.animationPopStyle];
        NSTimeInterval duration = (_popAnimationDuration < 0.0f) ? defaultDuration : _popAnimationDuration;
        if (self.animationPopStyle == WKAnimationPopStyleNO) {
            self.alpha = 0.0;
            if (self.isTransparent) {
                self.backgroundView.backgroundColor = [UIColor clearColor];
            } else {
                self.backgroundView.alpha = 0.0;
            }
            [UIView animateWithDuration:duration animations:^{
                ws.alpha = 1.0;
                if (!ws.isTransparent) {
                    ws.backgroundView.alpha = ws.popBGAlpha;
                }
            }];
        }
        else if (self.animationPopStyle == WKAnimationPopStyleBottomToTop)
        {
            if (ws.isTransparent) {
                self.backgroundView.backgroundColor = [UIColor clearColor];
            } else {
                self.backgroundView.alpha = 0.0;
                [UIView animateWithDuration:duration * 0.5 animations:^{
                    ws.backgroundView.alpha = ws.popBGAlpha;
                }];
            }
            _customView.frame = CGRectMake((SCREENWIDTH - _customView.bounds.size.width)/2.0, SCREENHEIGHT, _customView.bounds.size.width, _customView.bounds.size.height);
            [UIView animateWithDuration:duration animations:^{
                ws.customView.frame = CGRectMake((SCREENWIDTH - ws.customView.bounds.size.width)/2.0, SCREENHEIGHT - ws.customView.bounds.size.height, ws.customView.bounds.size.width, ws.customView.bounds.size.height);
            }];
        }
        else
        {
            if (ws.isTransparent) {
                self.backgroundView.backgroundColor = [UIColor clearColor];
            } else {
                self.backgroundView.alpha = 0.0;
                [UIView animateWithDuration:duration * 0.5 animations:^{
                    ws.backgroundView.alpha = ws.popBGAlpha;
                }];
            }
            [self hanlePopAnimationWithDuration:duration];
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (ws.popComplete) {
                ws.popComplete();
            }
        });
    }
}

- (void)dismiss
{
    __weak typeof(self) ws = self;
    NSTimeInterval defaultDuration = [self getDismissDefaultDuration:self.animationDismissStyle];
    NSTimeInterval duration = (_dismissAnimationDuration < 0.0f) ? defaultDuration : _dismissAnimationDuration;
    if (self.animationDismissStyle == WKAnimationPopStyleNO) {
        [UIView animateWithDuration:duration animations:^{
            ws.alpha = 0.0;
            ws.backgroundView.alpha = 0.0;
        }];
    }
    else if (self.animationDismissStyle == WKAnimationDismissStyleBottomToTop)
    {
        [UIView animateWithDuration:duration animations:^{
            ws.customView.frame = CGRectMake((SCREENWIDTH - ws.customView.bounds.size.width)/2.0, SCREENHEIGHT, ws.customView.bounds.size.width, ws.customView.bounds.size.height);
            ws.backgroundView.backgroundColor = RGBACOLOR(1, 1, 1, 0.0);
        } completion:^(BOOL finished) {
        }];
    }
    else
    {
        if (!ws.isTransparent) {
            [UIView animateWithDuration:duration * 0.5 animations:^{
                ws.backgroundView.alpha = 0.0;
            }];
        }
        [self hanleDismissAnimationWithDuration:duration];
    }
    
    if (ws.isObserverOrientationChange) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (ws.dismissComplete) {
            ws.dismissComplete();
        }
        [ws removeFromSuperview];
    });
}

- (void)hanlePopAnimationWithDuration:(NSTimeInterval)duration
{
    __weak typeof(self) ws = self;
    switch (self.animationPopStyle) {
        case WKAnimationPopStyleScale:
        {
            [self animationWithLayer:self.contentView.layer duration:duration values:@[@0.0, @1.2, @1.0]]; // 另外一组动画值(the other animation values) @[@0.0, @1.2, @0.9, @1.0]
        }
            break;
        case WKAnimationPopStyleShakeFromTop:
        case WKAnimationPopStyleShakeFromBottom:
        case WKAnimationPopStyleShakeFromLeft:
        case WKAnimationPopStyleShakeFromRight:
        {
            CGPoint startPosition = self.contentView.layer.position;
            if (self.animationPopStyle == WKAnimationPopStyleShakeFromTop) {
                self.contentView.layer.position = CGPointMake(startPosition.x, -startPosition.y);
            } else if (self.animationPopStyle == WKAnimationPopStyleShakeFromBottom) {
                self.contentView.layer.position = CGPointMake(startPosition.x, CGRectGetMaxY(self.frame) + startPosition.y);
            } else if (self.animationPopStyle == WKAnimationPopStyleShakeFromLeft) {
                self.contentView.layer.position = CGPointMake(-startPosition.x, startPosition.y);
            } else {
                self.contentView.layer.position = CGPointMake(CGRectGetMaxX(self.frame) + startPosition.x, startPosition.y);
            }
            
            [UIView animateWithDuration:duration animations:^{
                ws.contentView.layer.position = startPosition;
            }];
            
//            [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
//
//            } completion:nil];
        }
            break;
        case WKAnimationPopStyleCardDropFromLeft:
        case WKAnimationPopStyleCardDropFromRight:
        {
            CGPoint startPosition = self.contentView.layer.position;
            if (self.animationPopStyle == WKAnimationPopStyleCardDropFromLeft) {
                self.contentView.layer.position = CGPointMake(startPosition.x * 1.0, -startPosition.y);
                self.contentView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(15.0));
            } else {
                self.contentView.layer.position = CGPointMake(startPosition.x * 1.0, -startPosition.y);
                self.contentView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-15.0));
            }
            
            [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                ws.contentView.layer.position = startPosition;
            } completion:nil];
            
            [UIView animateWithDuration:duration*0.6 animations:^{
                ws.contentView.layer.transform = CATransform3DMakeRotation(DEGREES_TO_RADIANS((ws.animationPopStyle == WKAnimationPopStyleCardDropFromRight) ? 5.5 : -5.5), 0, 0, 0);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:duration*0.2 animations:^{
                    ws.contentView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS((ws.animationPopStyle == WKAnimationPopStyleCardDropFromRight) ? -1.0 : 1.0));
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:duration*0.2 animations:^{
                        ws.contentView.transform = CGAffineTransformMakeRotation(0.0);
                    } completion:nil];
                }];
            }];
        }
            break;
            
        default:
            break;
    }
}

- (void)hanleDismissAnimationWithDuration:(NSTimeInterval)duration
{
    __weak typeof(self) ws = self;
    switch (self.animationDismissStyle) {
        case WKAnimationDismissStyleScale:
        {
            [self animationWithLayer:self.contentView.layer duration:duration values:@[@1.0, @0.66, @0.33, @0.01]];
        }
            break;
        case WKAnimationDismissStyleDropToTop:
        case WKAnimationDismissStyleDropToBottom:
        case WKAnimationDismissStyleDropToLeft:
        case WKAnimationDismissStyleDropToRight:
        {
            CGPoint startPosition = self.contentView.layer.position;
            CGPoint endPosition = self.contentView.layer.position;
            if (self.animationDismissStyle == WKAnimationDismissStyleDropToTop) {
                endPosition = CGPointMake(startPosition.x, -startPosition.y);
            } else if (self.animationDismissStyle == WKAnimationDismissStyleDropToBottom) {
                endPosition = CGPointMake(startPosition.x, CGRectGetMaxY(self.frame) + startPosition.y);
            } else if (self.animationDismissStyle == WKAnimationDismissStyleDropToLeft) {
                endPosition = CGPointMake(-startPosition.x, startPosition.y);
            } else {
                endPosition = CGPointMake(CGRectGetMaxX(self.frame) + startPosition.x, startPosition.y);
            }
            
            [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                ws.contentView.layer.position = endPosition;
            } completion:nil];
        }
            break;
        case WKAnimationDismissStyleCardDropToLeft:
        case WKAnimationDismissStyleCardDropToRight:
        {
            CGPoint startPosition = self.contentView.layer.position;
            BOOL isLandscape = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
            __block CGFloat rotateEndY = 0.0f;
            [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                if (self.animationDismissStyle == WKAnimationDismissStyleCardDropToLeft) {
                    ws.contentView.transform = CGAffineTransformMakeRotation(M_1_PI * 0.75);
                    if (isLandscape) rotateEndY = fabs(ws.contentView.frame.origin.y);
                    ws.contentView.layer.position = CGPointMake(startPosition.x, CGRectGetMaxY(ws.frame) + startPosition.y + rotateEndY);
                } else {
                    ws.contentView.transform = CGAffineTransformMakeRotation(-M_1_PI * 0.75);
                    if (isLandscape) rotateEndY = fabs(ws.contentView.frame.origin.y);
                    ws.contentView.layer.position = CGPointMake(startPosition.x * 1.25, CGRectGetMaxY(ws.frame) + startPosition.y + rotateEndY);
                }
            } completion:nil];
        }
            break;
        case WKAnimationDismissStyleCardDropToTop:
        {
            CGPoint startPosition = self.contentView.layer.position;
            CGPoint endPosition = CGPointMake(startPosition.x, -startPosition.y);
            [UIView animateWithDuration:duration*0.2 animations:^{
                ws.contentView.layer.position = CGPointMake(startPosition.x, startPosition.y + 50.0f);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:duration*0.8 animations:^{
                    ws.contentView.layer.position = endPosition;
                } completion:nil];
            }];
        }
            break;
        default:
            break;
    }
}

- (NSTimeInterval)getPopDefaultDuration:(WKAnimationPopStyle)animationPopStyle
{
    NSTimeInterval defaultDuration = 0.0f;
    if (animationPopStyle == WKAnimationPopStyleNO || animationPopStyle == WKAnimationPopStyleBottomToTop) {
        defaultDuration = 0.2f;
    } else if (animationPopStyle == WKAnimationPopStyleScale) {
        defaultDuration = 0.3f;
    } else if (animationPopStyle == WKAnimationPopStyleShakeFromTop ||
               animationPopStyle == WKAnimationPopStyleShakeFromBottom ||
               animationPopStyle == WKAnimationPopStyleShakeFromLeft ||
               animationPopStyle == WKAnimationPopStyleShakeFromRight ||
               animationPopStyle == WKAnimationPopStyleCardDropFromLeft ||
               animationPopStyle == WKAnimationPopStyleCardDropFromRight) {
        defaultDuration = 0.8f;
    }
    return defaultDuration;
}

- (NSTimeInterval)getDismissDefaultDuration:(WKAnimationDismissStyle)animationDismissStyle
{
    NSTimeInterval defaultDuration = 0.0f;
    if (animationDismissStyle == WKAnimationDismissStyleNO || animationDismissStyle == WKAnimationDismissStyleBottomToTop) {
        defaultDuration = 0.2f;
    } else if (animationDismissStyle == WKAnimationDismissStyleScale) {
        defaultDuration = 0.2f;
    } else if (animationDismissStyle == WKAnimationDismissStyleDropToTop ||
               animationDismissStyle == WKAnimationDismissStyleDropToBottom ||
               animationDismissStyle == WKAnimationDismissStyleDropToLeft ||
               animationDismissStyle == WKAnimationDismissStyleDropToRight ||
               animationDismissStyle == WKAnimationDismissStyleCardDropToLeft ||
               animationDismissStyle == WKAnimationDismissStyleCardDropToRight ||
               animationDismissStyle == WKAnimationDismissStyleCardDropToTop) {
        defaultDuration = 0.8f;
    }
    return defaultDuration;
}

- (void)animationWithLayer:(CALayer *)layer duration:(CGFloat)duration values:(NSArray *)values
{
    CAKeyframeAnimation *KFAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    KFAnimation.duration = duration;
    KFAnimation.removedOnCompletion = NO;
    KFAnimation.fillMode = kCAFillModeForwards;
    
    NSMutableArray *valueArr = [NSMutableArray arrayWithCapacity:values.count];
    for (NSUInteger i = 0; i<values.count; i++) {
        CGFloat scaleValue = [values[i] floatValue];
        [valueArr addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(scaleValue, scaleValue, scaleValue)]];
    }
    KFAnimation.values = valueArr;
    KFAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [layer addAnimation:KFAnimation forKey:nil];
}

#pragma mark 监听横竖屏方向改变
- (void)statusBarOrientationChange:(NSNotification *)notification
{
    CGRect startCustomViewRect = self.customView.frame;
    self.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    self.backgroundView.frame = self.bounds;
    self.contentView.frame = self.bounds;
    self.customView.frame = startCustomViewRect;
    self.customView.center = self.center;
}


+ (UIViewController *)getCurrentController:(UIViewController*)rootViewController
{
    if ([rootViewController isKindOfClass:[UITabBarController class]])
    {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self getCurrentController:tabBarController.selectedViewController];
    }
    else if ([rootViewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self getCurrentController:navigationController.visibleViewController];
    }
    else if (rootViewController.presentedViewController)
    {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self getCurrentController:presentedViewController];
    }
    else
    {
        return rootViewController;
    }
}


@end
