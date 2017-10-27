//
//  UIImage_XMImage.h
//  XMMyImage
//
//  Created by mifit on 15/9/5.
//  Copyright (c) 2015年 mifit. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, EnSvCrop) {
    EnSvCropClip,
    EnSvCropExpand
};

/*
 *  图片基本操作类
 */
@interface UIImage(XMImage)
/**
 拷贝图片一部分
 @param     rect 拷贝范围
 @return    UIImage 图片
 */
- (UIImage *)imageByCroppingRect:(CGRect)rect;

/**
 获取图片某个点的颜色
 @param     point 某个点
 @return    UIColor 颜色
 */
- (UIColor *)colorAtPixel:(CGPoint)point;

/// ----------------

/**
 调整图像饱和度
 @param     src     原图
 @param     sValue  饱和度值    0 -- 2     default:1
 @return    UIImage 结果
 */
+ (UIImage *)saturationImage:(UIImage *)src vlaue:(CGFloat)sValue;

/**
 图像锐化
 @param     src     原图
 @param     sValue  锐化值    0 -- 2    default：0.4
 @return    UIImage 结果
 */
+ (UIImage *)sharpenImage:(UIImage *)src vlaue:(CGFloat)sValue;
/**
 调整图像色温
 @param     src     原图
 @param     tValue  色温    warm：2700k-3000k     cool: 5000k   Range:1700k-27000k
 @return    UIImage 结果
 */
+ (UIImage *)temperatureAndTintImage:(UIImage *)src vlaue:(NSInteger)tValue;

/**
 调整图像亮度
 @param     src     原图
 @param     bValue  亮度    -1 -- 1   default:0
 @return    UIImage 结果
 */
+ (UIImage *)brightnessImage:(UIImage *)src vlaue:(CGFloat)bValue;

/**
 调整图像对比度
 @param     src     原图
 @param     cValue  亮度    0.25 -- 4    default:1
 @return    UIImage 结果
 */
+ (UIImage *)contrastImage:(UIImage *)src vlaue:(CGFloat)cValue;

/**
 调整图像  亮度、对比度、色温、饱和度、锐化        key：brightness、contrast、temperature、saturation、sharpen
 @param     src     原图
 @param     value  亮度
 @return    UIImage 结果
 */
+ (UIImage *)adjustImage:(UIImage *)src vlaue:(NSDictionary *)value;

/**
 自动调整图像
 @param     src     原图
 @return    UIImage 结果
 */
+ (UIImage *)autoAdjustImage:(UIImage *)src;

/**
 灰阶图片
 @param     source  原图
 @return    UIImage 结果图片
 */
+ (UIImage *)grayImage:(UIImage *)source;

/**
 二值化图片
 @param     img     原图
 @return    UIImage 结果图片
 */
+ (UIImage *)convertToGrayscale:(UIImage*)img;

/**
 图片缩放到指定大小
 @param     img     原图
 @param     size    大小
 @return    UIImage 结果图片
 */
+ (UIImage *)scaleImage:(UIImage *)img toSize:(CGSize)size;

+ (UIImage *)maskImage:(CGSize)size ridus:(CGFloat)radius;

/**
    双环渐变模糊效果
 @param     image       原图
 @param     blurVal     模糊强度 0-100
 @return    center      中心，单位图片像素       原坐标在左下角
 @return    radius      环半径，单位图片像素
 @return    offset      半径偏移，单位图片像素
 */
+ (UIImage *)bluerImage:(UIImage *)image
              blurLevel:(NSInteger)blurVal
                 center:(CGPoint)center
                 radius:(CGFloat)radius
                 offset:(CGFloat)offset;

/**
 双线渐变模糊效果
 @param     image       原图
 @param     blurVal     模糊强度 0-100
 @param     center      中心位置位置，单位图片像素   原坐标在左下角
 @param     with        清晰视野宽度，单位图片像素angle
 @param     angle       旋转角度，弧度制
 */
+ (UIImage *)bluerImage:(UIImage *)image
              blurLevel:(NSInteger)blurVal
                     at:(CGPoint)center
                   with:(CGFloat)with
               rotation:(CGFloat)angle;

/**
 暗角效果
 @param     img         原图
 @param     radius      半径 0-2000
 @param     val         强度  -1--1
 @param     UIImage     结果
 */
+ (UIImage *)vignetteImage:(UIImage *)img radius:(CGFloat)radius intensity:(CGFloat)val;

/**
 随机指定路径图片的一部分，大小不定。
 @param     path 图片路径
 @return    UIImage 图片
 */
+ (UIImage *)randomImage:(NSString *)path;

/**
 随机一个颜色
 @return    UIColor 颜色
 */
+ (UIColor *)randomColor;

/**
 获取某个图片的某个点的颜色
 @return    UIColor 颜色
 */
+ (UIColor*)pixelColorAt:(CGPoint)point inImage:(UIImage *)image;

/**
 生成指定颜色的图片
 @param     color 图片颜色
 @param     size 图片大小
 @return    UIImage 图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

/**
 图片左右镜像
 @param     image 图片
 @return    UIImage 图片
 */
+ (UIImage *)leftRightMirror:(UIImage *)image;

/**
 图片上下镜像
 @param     image 图片
 @return    UIImage 图片
 */
+ (UIImage *)upDownMirror:(UIImage *)image;


/**
 图片旋转   
 @param     image 图片
 @param     orientation 图片旋转方向
 @return    UIImage 图片
 */
+ (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation;

+ (UIImage *)fixOrientation:(UIImage *)aImage;

/*
 旋转图片
 @prama radian 旋转角度
 @prama cropMode 旋转模式，Clip会剪切超出的部分，Expand会填充空白部分
 */
+ (UIImage*)rotateImageWithRadian:(CGFloat)radian img:(UIImage *)img cropMode:(EnSvCrop)cropMode;

/**
 给图片添加文字
 @param     img 图片
 @param     text1 文本
 @return    UIImage 图片
 */
+ (UIImage*)addText:(UIImage *)img text:(NSString*)text1;

/**
 给图片添加文字            缩放、旋转无效
 @param     img 图片
 @param     text1   文本
 @param     pt      文本位置
 @param     angle   文本旋转角度
 @param     scale   文本缩放比例
 @param     attr    文本attribute
 @return    UIImage 图片
 */
+ (UIImage*)addText:(UIImage *)img
               text:(NSString*)text
                 at:(CGPoint)pt
           rotation:(CGFloat)angle
              scale:(CGFloat)scale
               attr:(NSDictionary *)attr;


/**
 给图片添加logo
 @param     img 图片
 @param     logo logo
 @return    UIImage 图片
 */
+ (UIImage*)addImageLogo:(UIImage *)img text:(UIImage*)logo;

/**
 给图片添加水印
 @param     useImage 图片
 @param     addImage1 水印图
 @return    UIImage 图片
 */
+ (UIImage*)addImage:(UIImage *)useImage addImage1:(UIImage*)addImage1;

/**
 获取scrollview截屏
 @param     scrollView 滚动视图
 @return    UIImage 图片
 */
+ (UIImage *)captureScrollView:(UIScrollView *)scrollView;
@end
