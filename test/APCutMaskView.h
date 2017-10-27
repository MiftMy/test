//
//  APCutMaskView.h
//  test
//
//  Created by mifit on 2017/9/29.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APCutMaskView : UIView
@property (nonatomic, assign) CGSize imgSize;
@property (nonatomic, assign) CGRect imgRectInIV;
@property (nonatomic, assign) CGFloat scScale;
@property (nonatomic, assign) CGRect showRect;//将要显示裁剪框的rect
@property (nonatomic, assign) CGFloat whRate;//裁剪框的宽高比。  负数=自由。

//手势拖动后缩放多少，rect为裁剪框当前位置
@property (nonatomic, copy) void (^zoomScale)(CGFloat scale, CGRect fRect, CGRect tRect);
@end
