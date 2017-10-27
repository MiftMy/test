//
//  XMTool.m
//  test
//
//  Created by mifit on 2017/10/9.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import "XMTool.h"

@implementation XMTool
//平面上的三点面积：S(P1,P2,P3)=|y1 y2 y3|= [(x1-x3)*(y2-y3)-(y1-y3)*(x2-x3)]/2
//当P1P2P3逆时针时S为正的，当P1P2P3顺时针时S为负的。
//令矢量的起点为A，终点为B，判断的点为C，
//如果S（A，B，C）为正数，则C在矢量AB的左侧；
//如果S（A，B，C）为负数，则C在矢量AB的右侧；
//如果S（A，B，C）为0，则C在直线AB上。
+ (CGFloat)pointPosition:(CGPoint)pt3 atPoint:(CGPoint)pt1 to:(CGPoint)pt2 {
    CGFloat area = ((pt1.x-pt3.x)*(pt2.y-pt3.y)-(pt1.y-pt3.y)*(pt2.x-pt3.x))/2;
    return area;
}

//任意点(x,y)，绕一个坐标点(rx0,ry0)逆时针旋转a角度后的新的坐标设为(x0, y0)
//x0= (x - rx0)*cos(a) - (y - ry0)*sin(a) + rx0 ;
//y0= (x - rx0)*sin(a) + (y - ry0)*cos(a) + ry0 ;
+ (CGPoint)rotationPoint:(CGPoint)point atCenter:(CGPoint)center angle:(CGFloat)angle {
    CGFloat x0 = (point.x - center.x)*cos(angle) - (point.y - center.y)*sin(angle) + center.x;
    CGFloat y0 = (point.x - center.x)*sin(angle) + (point.y - center.y)*cos(angle) + center.y;
    return CGPointMake(x0, y0);
}

+ (CGPoint)point:(CGPoint)point rotationCoordinateAtCenter:(CGPoint)center angle:(CGFloat)angle {
    // 0点旋转后
    CGPoint z0 = [self rotationPoint:CGPointMake(0, 0) atCenter:center angle:angle];
    //x轴上的点旋转后
    CGPoint zx = [self rotationPoint:CGPointMake(1, 0) atCenter:center angle:angle];
    //y轴上的点旋转后
    CGPoint zy = [self rotationPoint:CGPointMake(0, 1) atCenter:center angle:angle];
    //三点旋转后形成新的坐标系，只要求出point到该坐标系的距离，判断正负即可就出新坐标系上对应的点坐标
    
    //point到两个轴的法向量距离
    CGFloat xVal = [self distanceFromPt:point toPt:z0 andPt:zy];
    CGFloat yVal = [self distanceFromPt:point toPt:z0 andPt:zx];
    //点在新坐标系x轴的右边，y为负数
    CGFloat vY = [self pointPosition:point atPoint:z0 to:zx];
    if (0 > vY) {
        yVal = -yVal;
    }
    //点在新坐标系y轴的左边,x为负数
    CGFloat vX = [self pointPosition:point atPoint:z0 to:zy];
    if (0 < vX) {
        xVal = -xVal;
    }
    return CGPointMake(xVal, yVal);
}

+ (CGPoint)scalePoint:(CGPoint)point atCenter:(CGPoint)center scale:(CGFloat)scale {
    CGFloat ptX = scale*point.x-scale*center.x+center.x;
    CGFloat ptY = scale*point.y-scale*center.y+center.y;
    return CGPointMake(ptX, ptY);
}

+ (CGFloat)distanceFromPt:(CGPoint)pt3 toPt:(CGPoint)pt1 andPt:(CGPoint)pt2 {
    //向量a
    CGPoint vt1 = CGPointMake(pt1.x-pt3.x, pt1.y-pt3.y);
    //向量b
    CGPoint vt2 = CGPointMake(pt1.x-pt2.x, pt1.y-pt2.y);
    //向量b的模
    CGFloat vt2M = vt2.x*vt2.x + vt2.y*vt2.y;
    //向量a、b点成
    CGFloat vt12x = vt1.x*vt2.x + vt1.y*vt2.y;
    CGFloat k = vt12x/vt2M;
    //向量c
    CGPoint vt3 = CGPointMake(vt2.x*k, vt2.y*k);
    //距离向量e
    CGPoint vtDes = CGPointMake(vt1.x-vt3.x, vt1.y-vt3.y);
    return sqrt(vtDes.x*vtDes.x+vtDes.y*vtDes.y);
}

+ (CGFloat)distanceBetwinPoint:(CGPoint)pt1 andPt:(CGPoint)pt2 {
    return sqrt((pt1.x-pt2.x)*(pt1.x-pt2.x)+(pt1.y-pt2.y)*(pt1.y-pt2.y));
}
@end
