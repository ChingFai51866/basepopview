//
//  QDBasePopView.m
//  QDYuYin
//
//  Created by mac on 2020/11/18.
//  Copyright © 2020 px. All rights reserved.
//

#import "QDBasePopView.h"

@interface QDBasePopView()
@property (nonatomic, weak) QDAnimationPopView *popView;
@end

@implementation QDBasePopView

- (void)dealloc
{
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _popStyle = WKAnimationPopStyleScale;
        _dismissStyle = WKAnimationDismissStyleScale;
        _isClickBGDismiss = YES;
        _popBGAlpha = 0.5f;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _popStyle = WKAnimationPopStyleScale;
        _dismissStyle = WKAnimationDismissStyleScale;
        _isClickBGDismiss = YES;
        _popBGAlpha = 0.5f;
    }
    return self;
}

- (void)show
{
    QDAnimationPopView *pop = [[QDAnimationPopView alloc] initWithCustomView:self popStyle:self.popStyle dismissStyle:self.dismissStyle];
    if (self.popAnimationDuration > 0) {
        pop.popAnimationDuration = self.popAnimationDuration;
    }
    pop.popBGAlpha = self.popBGAlpha;
    _popView = pop;
    
    _popView.isClickBGDismiss = self.isClickBGDismiss;
    
    __weak typeof(self)weakself = self;
    _popView.popComplete = ^{
        if (weakself.popComplete) {
            weakself.popComplete();
        }
    };

    _popView.dismissComplete = ^{
        if (weakself.dismissComplete) {
            weakself.dismissComplete();
        }
    };
    
    _popView.clickBgHandler = ^{
        [weakself clickBgMethod];
    };
    
    if (self.addOnView) {
        [_popView addOnView:self.addOnView];
    } else {
        [_popView pop:_isAddOnView];
    }
}

- (void)setIsClickBGDismiss:(BOOL)isClickBGDismiss
{
    _isClickBGDismiss = isClickBGDismiss;
    _popView.isClickBGDismiss = isClickBGDismiss;
}


- (void)dismiss
{
    [_popView dismiss];
}

- (void)clickBgMethod {
    if (self.clickBgHandler) {
        self.clickBgHandler();
    }
}


@end
