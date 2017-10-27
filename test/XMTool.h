//
//  XMTool.h
//  test
//
//  Created by mifit on 2017/10/9.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMTool : NSObject

/*
 *  判断一个点是在一向量左、右边or向量上
 *  @param pt3 点
 *  @param pt1 向量起点
 *  @param pt2 向量终点
 *  @return    0：向量上or延长线上  正数：左边  负数：右边
 */
+ (CGFloat)pointPosition:(CGPoint)pt3 atPoint:(CGPoint)pt1 to:(CGPoint)pt2;

/*
 *  点绕某一点旋转角度后的坐标               旋转点
 *  @param point    需要旋转的坐标
 *  @param center   旋转中心
 *  @param angle    旋转角度，逆时针为正，顺时针为负
 *  @return         旋转后的坐标
 */
+ (CGPoint)rotationPoint:(CGPoint)point atCenter:(CGPoint)center angle:(CGFloat)angle;

/*
 *  垂直坐标系上的点，当坐标系绕某一点旋转一定角度的后的坐标     旋转坐标系
 *  @param point    需要旋转的坐标
 *  @param center   旋转中心
 *  @param angle    旋转角度，逆时针为正，顺时针为负
 *  @return         旋转后的坐标
 */
+ (CGPoint)point:(CGPoint)point rotationCoordinateAtCenter:(CGPoint)center angle:(CGFloat)angle;

/*
 *  点距离中心点距离放大
 *  @param point    需要旋转的坐标
 *  @param center   旋转中心
 *  @param angle    旋转角度
 *  @return         旋转后的坐标
 */
+ (CGPoint)scalePoint:(CGPoint)point atCenter:(CGPoint)center scale:(CGFloat)scale;

/*
 *  点到两点组成的直线距离
 *  @param pt3   点
 *  @param pt1   直线点1
 *  @param pt2   直线点2
 *  @return      点到线距离
 */
+ (CGFloat)distanceFromPt:(CGPoint)pt3 toPt:(CGPoint)pt1 andPt:(CGPoint)pt2;

/*
 *  两点距离
 *  @param pt1   点1
 *  @param pt2   点2
 *  @return      两点距离
 */
+ (CGFloat)distanceBetwinPoint:(CGPoint)pt1 andPt:(CGPoint)pt2;


@end
