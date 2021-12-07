# basepopview
ios 弹框动画
集成basepopview,设置popstyle,dissmissStyle, addview,调show方法即可

 TestPopView * popView = [[TestPopView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
   popView.backgroundColor = [UIColor redColor];
    
   //根据需要设置不同的弹出动画
   switch (row) {
       case 0:
           break;
        case 1:
            popView.popStyle = WKAnimationPopStyleShakeFromTop;
            popView.dismissStyle = WKAnimationDismissStyleDropToTop;
          break;
       case 2:
            popView.popStyle = WKAnimationPopStyleShakeFromBottom;
            popView.dismissStyle = WKAnimationDismissStyleDropToBottom;
            break;
        case 3:
            popView.popStyle = WKAnimationPopStyleBottomToTop;
            popView.dismissStyle = WKAnimationDismissStyleBottomToTop;
            break;
        default:
            break;
    }
    //添加到的superview
    popView.addOnView = self.view;
    [popView show];
