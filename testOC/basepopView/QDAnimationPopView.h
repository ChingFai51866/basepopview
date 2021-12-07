//
//  QDAnimationPopView.h
//  QDYuYin
//
//  Created by mac on 2020/11/18.
//  Copyright © 2020 px. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, WKAnimationPopStyle) {
    WKAnimationPopStyleNO = 0,               ///< 无动画
    WKAnimationPopStyleScale,                ///< 缩放动画，先放大，后恢复至原大小
    WKAnimationPopStyleShakeFromTop,         ///< 从顶部掉下到中间晃动动画
    WKAnimationPopStyleShakeFromBottom,      ///< 从底部往上到中间晃动动画
    WKAnimationPopStyleShakeFromLeft,        ///< 从左侧往右到中间晃动动画
    WKAnimationPopStyleShakeFromRight,       ///< 从右侧往左到中间晃动动画
    WKAnimationPopStyleCardDropFromLeft,     ///< 卡片从顶部左侧开始掉落动画
    WKAnimationPopStyleCardDropFromRight,    ///< 卡片从顶部右侧开始掉落动画
    WKAnimationPopStyleBottomToTop,          ///< 从最下方弹出动画

};

/**
 移除时动画弹框样式
 */
typedef NS_ENUM(NSInteger, WKAnimationDismissStyle) {
    WKAnimationDismissStyleNO = 0,               ///< 无动画
    WKAnimationDismissStyleScale,                ///< 缩放动画
    WKAnimationDismissStyleDropToTop,            ///< 从中间直接掉落到顶部
    WKAnimationDismissStyleDropToBottom,         ///< 从中间直接掉落到底部
    WKAnimationDismissStyleDropToLeft,           ///< 从中间直接掉落到左侧
    WKAnimationDismissStyleDropToRight,          ///< 从中间直接掉落到右侧
    WKAnimationDismissStyleCardDropToLeft,       ///< 卡片从中间往左侧掉落
    WKAnimationDismissStyleCardDropToRight,      ///< 卡片从中间往右侧掉落
    WKAnimationDismissStyleCardDropToTop,        ///< 卡片从中间往顶部移动消失
    WKAnimationDismissStyleBottomToTop,              ///< 从往下方消失动画
};
@interface QDAnimationPopView : UIView


/** 显示时点击背景是否移除弹框，默认为NO。 */
@property (nonatomic) BOOL isClickBGDismiss;
/** 显示时是否监听屏幕旋转，默认为NO */
@property (nonatomic) BOOL isObserverOrientationChange;
/** 显示时背景的透明度，取值(0.0~1.0)，默认为0.5 */
@property (nonatomic) CGFloat popBGAlpha;

/// 动画相关属性参数
/** 显示时动画时长，>= 0。不设置则使用默认的动画时长 */
@property (nonatomic) CGFloat popAnimationDuration;
/** 隐藏时动画时长，>= 0。不设置则使用默认的动画时长 */
@property (nonatomic) CGFloat dismissAnimationDuration;
/** 显示完成回调 */
@property (nullable, nonatomic, copy) void(^popComplete)(void);
/** 移除完成回调 */
@property (nullable, nonatomic, copy) void(^dismissComplete)(void);
//点击背景回调
@property (nonatomic, copy) void(^ _Nullable clickBgHandler) (void);


/**
 通过自定义视图来构造弹框视图
 
 @param customView 自定义视图
 */
- (nullable instancetype)initWithCustomView:(UIView *_Nonnull)customView
                                   popStyle:(WKAnimationPopStyle)popStyle
                               dismissStyle:(WKAnimationDismissStyle)dismissStyle;

/**
 显示弹框
 */
- (void)pop:(BOOL)isAddOnView;

// 添加到指定的view
-(void)addOnView:(UIView *_Nullable)bgView;

/**
 移除弹框
 */
- (void)dismiss;


@end




