//
//  QDBasePopView.h
//  QDYuYin
//
//  Created by mac on 2020/11/18.
//  Copyright © 2020 px. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QDAnimationPopView.h"

NS_ASSUME_NONNULL_BEGIN

@interface QDBasePopView : UIView

@property (nonatomic) BOOL isClickBGDismiss;

@property (nullable, nonatomic, copy) void(^popComplete)(void);
/** 移除完成回调 */
@property (nullable, nonatomic, copy) void(^dismissComplete)(void);

@property (nonatomic, copy) void(^clickBgHandler) (void);

@property (nonatomic, assign) WKAnimationPopStyle popStyle;

@property (nonatomic, assign) WKAnimationDismissStyle dismissStyle;

@property (nonatomic, assign) CGFloat popBGAlpha;

//@property (nonatomic, assign)Bool iSFrostedGlass;//毛玻璃效果

/** 加一个属性 判断popview是添加到window上还是当前页面view上 */
/*//在无addOnView参数的情况下设置yes意思就是当前vc的view上，如果设置addOnView了，此参数无效*/
@property (nonatomic, assign) BOOL isAddOnView;
@property (nonatomic, strong) UIView * addOnView;

@property (nonatomic, assign) CGFloat popAnimationDuration;//动画时间，此参数一般不用更改

- (void)show;
- (void)dismiss;

- (void)clickBgMethod;

@end

NS_ASSUME_NONNULL_END
