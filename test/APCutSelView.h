//
//  APCutSelView.h
//  test
//
//  Created by mifit on 2017/9/29.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APCutSelView : UIView
//当前裁剪框rect，相对基view，即APCutSelView
@property (nonatomic, readonly, assign) CGRect cutRect;//裁剪框rect
@property (nonatomic, readonly, assign) CGFloat scale;//缩放倍数
@property (nonatomic, assign) CGFloat angle;//自身旋转角度
@property (nonatomic, assign) CGFloat rotationAngle;//旋转角度
@property (nonatomic, assign) CGFloat whRate;//裁剪框的宽高比。  负数=自由。
@property (nonatomic, strong) UIImage *orgImg;

- (void)imageFromCurrent:(void (^)(UIImage *img))block;
@end
