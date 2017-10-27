//
//  APCutFrameView.h
//  test
//
//  Created by mifit on 2017/9/29.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, APGRActiveType) {
    APGRActiveTypeTopLeft = 1,
    APGRActiveTypeTopRight,
    APGRActiveTypeBottomRight,
    APGRActiveTypeBottomLeft,
    APGRActiveTypeTopMid,
    APGRActiveTypeRightMid,
    APGRActiveTypeBottomMid,
    APGRActiveTypeLeftMid
};
/*
 *  边线距离边相差 activeLen/2
 *
 */

@interface APCutFrameView : UIView
//触发角在框线上居中。触发角在线的中间和4个角上。

@property (nonatomic, assign) CGFloat activeLen; //触发角有效宽高， 默认30

@property (nonatomic, assign) BOOL isShowGrid;//是否显示网格
@property (nonatomic, assign) CGSize imgSize;//图片大小
@property (nonatomic, assign) APGRActiveType activeType;

- (NSInteger)checkActive:(CGPoint)point;
@end
