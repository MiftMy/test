//
//  XMImage.m
//  XMMyImage
//
//  Created by mifit on 15/9/5.
//  Copyright (c) 2015年 mifit. All rights reserved.
//

#import "UIImage_XMImage.h"


@implementation UIImage(XMImage)
#pragma mark - instance method
- (UIImage *)imageByCroppingRect:(CGRect)rect{
    rect = CGRectMake(rect.origin.x * self.scale,
                      rect.origin.y * self.scale,
                      rect.size.width * self.scale,
                      rect.size.height * self.scale);
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}

+ (UIImage *)imageByCroppingRect:(CGRect)rect image:(UIImage *)img{
    rect = CGRectMake(rect.origin.x * img.scale,
                      rect.origin.y * img.scale,
                      rect.size.width * img.scale,
                      rect.size.height * img.scale);
    CGImageRef imageRef = CGImageCreateWithImageInRect(img.CGImage, rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:img.scale orientation:img.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}

- (UIImage *)imageByDrawingColoredText:(NSString *)text{
    const CGSize size = self.size;
    const CGFloat pointSize = MIN(size.width, size.height) / 2;
    UIFont *font = [UIFont boldSystemFontOfSize:pointSize];
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIColor *color = [UIImage randomColor];
    NSDictionary *attributes = @{NSFontAttributeName : font, NSForegroundColorAttributeName : color};
    CGSize textSize = [text sizeWithAttributes:attributes];
    CGRect rect = CGRectMake((size.width - textSize.width) / 2, (size.height - textSize.height) / 2, textSize.width, textSize.height);
    [text drawInRect:rect withAttributes:attributes];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIColor *)colorAtPixel:(CGPoint)point {
    // Cancel if point is outside image coordinates
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, self.size.width, self.size.height), point)) {
        return nil;
    }
    
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = self.CGImage;
    NSUInteger width = self.size.width;
    NSUInteger height = self.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    // Draw the pixel we are interested in onto the bitmap context
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    // Convert color values [0..255] to floats [0.0..1.0]
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

#pragma mark - class method
+ (UIImage *)saturationImage:(UIImage *)src vlaue:(CGFloat)sValue {
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *superImage = [CIImage imageWithCGImage:src.CGImage];
    CIFilter *lighten = [CIFilter filterWithName:@"CIColorControls"];
    [lighten setValue:superImage forKey:kCIInputImageKey];
    [lighten setValue:@(sValue) forKey:@"inputSaturation"];
//    NSLog(@"%@", lighten.attributes);
    CIImage *result = [lighten valueForKey:kCIOutputImageKey];
    CGImageRef cgImage = [context createCGImage:result fromRect:[superImage extent]];
    UIImage *myImage = [UIImage imageWithCGImage:cgImage];
    
    // 释放对象
    CGImageRelease(cgImage);
    return myImage;
}
+ (UIImage *)sharpenImage:(UIImage *)src vlaue:(CGFloat)sValue {
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *superImage = [CIImage imageWithCGImage:src.CGImage];
//    NSLog(@"%@", [CIFilter filterNamesInCategory:kCICategorySharpen]);
    CIFilter *sharpen = [CIFilter filterWithName:@"CISharpenLuminance"];
//    NSLog(@"%@", sharpen);
//    NSLog(@"%@", sharpen.attributes);
    [sharpen setValue:superImage forKey:kCIInputImageKey];
    [sharpen setValue:@(sValue) forKey:@"inputSharpness"];
    
    CIImage *result = [sharpen valueForKey:kCIOutputImageKey];
    CGImageRef cgImage = [context createCGImage:result fromRect:[superImage extent]];
    UIImage *myImage = [UIImage imageWithCGImage:cgImage];
    
    // 释放对象
    CGImageRelease(cgImage);
    return myImage;
}

+ (UIImage *)temperatureAndTintImage:(UIImage *)src vlaue:(NSInteger)tValue {
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *superImage = [CIImage imageWithCGImage:src.CGImage];
    CIFilter *yourFilter = [CIFilter filterWithName:@"CITemperatureAndTint"];
    NSLog(@"%@", yourFilter.attributes);
    [yourFilter setValue:superImage forKey:@"inputImage"];
    [yourFilter setValue:[CIVector vectorWithX:6500 Y:0] forKey:@"inputNeutral"]; // Default value: [6500, 0] Identity: [6500, 0]
    [yourFilter setValue:[CIVector vectorWithX:tValue Y:0] forKey:@"inputTargetNeutral"]; // Default value: [6500, 0] Identity: [6500, 0]
    CIImage *resultImage = [yourFilter valueForKey: kCIOutputImageKey];
    CGImageRef cgImage = [context createCGImage:resultImage fromRect:resultImage.extent];
    UIImage *resultOutputImage = [UIImage imageWithCGImage:cgImage];
    // 释放对象
    CGImageRelease(cgImage);
    return resultOutputImage;
}

+ (UIImage *)brightnessImage:(UIImage *)src vlaue:(CGFloat)bValue {
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *superImage = [CIImage imageWithCGImage:src.CGImage];
    CIFilter *lighten = [CIFilter filterWithName:@"CIColorControls"];
//    NSLog(@"%@", lighten.attributes);
    [lighten setValue:superImage forKey:kCIInputImageKey];
    [lighten setValue:@(bValue) forKey:@"inputBrightness"];
    
    CIImage *result = [lighten valueForKey:kCIOutputImageKey];
    CGImageRef cgImage = [context createCGImage:result fromRect:[superImage extent]];
    
    // 得到修改后的图片
    UIImage *myImage = [UIImage imageWithCGImage:cgImage];
    
    // 释放对象
    CGImageRelease(cgImage);
    return myImage;
}

+ (UIImage *)contrastImage:(UIImage *)src vlaue:(CGFloat)cValue {
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *superImage = [CIImage imageWithCGImage:src.CGImage];
    CIFilter *lighten = [CIFilter filterWithName:@"CIColorControls"];
    [lighten setValue:superImage forKey:kCIInputImageKey];
    [lighten setValue:@(cValue) forKey:@"inputContrast"];
    NSLog(@"%@", lighten.attributes);
    CIImage *result = [lighten valueForKey:kCIOutputImageKey];
    CGImageRef cgImage = [context createCGImage:result fromRect:[superImage extent]];
    
    // 得到修改后的图片
    UIImage *myImage = [UIImage imageWithCGImage:cgImage];
    
    // 释放对象
    CGImageRelease(cgImage);
    return myImage;
}

+ (UIImage *)adjustImage:(UIImage *)src vlaue:(NSDictionary *)value {
    NSNumber *brightnessVal = value[@"brightness"];;
    NSNumber *contrastVal = value[@"contrast"];
    NSNumber *temperatureVal = value[@"temperature"];
    NSNumber *saturationVal = value[@"saturation"];
    NSNumber *sharpenVal = value[@"sharpen"];
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *superImage = [CIImage imageWithCGImage:src.CGImage];
    CIFilter *desFilter = nil;
    if (brightnessVal || saturationVal || contrastVal) {
        CIFilter *colorControls = [CIFilter filterWithName:@"CIColorControls"];
//        NSLog(@"%@", colorControls.attributes);
        [colorControls setValue:superImage forKey:kCIInputImageKey];
        if (brightnessVal) {
            [colorControls setValue:brightnessVal forKey:@"inputBrightness"];
        }
        if (saturationVal) {
            [colorControls setValue:saturationVal forKey:@"inputSaturation"];
        }
        if (contrastVal) {
            [colorControls setValue:contrastVal forKey:@"inputContrast"];
        }
        desFilter = colorControls;
    }
    
    if (sharpenVal) {
        CIFilter *sharpenLuminance = [CIFilter filterWithName:@"CISharpenLuminance"];
        NSLog(@"%@", sharpenLuminance.attributes);
        [sharpenLuminance setValue:desFilter.outputImage forKey:kCIInputImageKey];
        [sharpenLuminance setValue:sharpenVal forKey:@"inputSharpness"];
        desFilter = sharpenLuminance;
    }
    if (temperatureVal) {
        CIFilter *temperature = [CIFilter filterWithName:@"CITemperatureAndTint"];
        [temperature setValue:desFilter.outputImage forKey:@"inputImage"];
        [temperature setValue:[CIVector vectorWithX:6500 Y:0] forKey:@"inputNeutral"]; // Default value: [6500, 0] Identity: [6500, 0]
        [temperature setValue:[CIVector vectorWithX:temperatureVal.integerValue Y:0] forKey:@"inputTargetNeutral"]; // Default value: [6500, 0] Identity: [6500, 0]
        desFilter = temperature;
    }
    
    CIImage *result = [desFilter valueForKey:kCIOutputImageKey];
    CGImageRef cgImage = [context createCGImage:result fromRect:[superImage extent]];
    
    // 得到修改后的图片
    UIImage *myImage = [UIImage imageWithCGImage:cgImage];
    
    // 释放对象
    CGImageRelease(cgImage);
    return myImage;
}

+ (UIImage *)autoAdjustImage:(UIImage *)src {
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *superImage = [CIImage imageWithCGImage:src.CGImage];
    
    for (CIFilter *filter in superImage.autoAdjustmentFilters) {
        [filter setValue:superImage forKey:@"inputImage"];
        superImage = filter.outputImage;
    }
    CIImage *result = [superImage valueForKey:kCIOutputImageKey];
    CGImageRef cgImage = [context createCGImage:result fromRect:[superImage extent]];
    // 得到修改后的图片
    UIImage *myImage = [UIImage imageWithCGImage:cgImage];
    // 释放对象
    CGImageRelease(cgImage);
    return myImage;
}

+ (UIImage *)grayImage:(UIImage *)source {
    NSInteger width = source.size.width;
    NSInteger height = source.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    CGContextRef context = CGBitmapContextCreate (nil,
                                                  width,
                                                  height,
                                                  8,      // bits per component
                                                  0,
                                                  colorSpace,
                                                  kCGImageAlphaNone);
    
    CGColorSpaceRelease(colorSpace);
    
    if (context == NULL) {
        return nil;
    }
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), source.CGImage);
    
    UIImage *grayImage = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
    CGContextRelease(context);
    
    return grayImage;
}

//二值化
+ (UIImage *)convertToGrayscale:(UIImage*)img {
    
    CGSize size = [img size];
    int width = size.width;
    int height = size.height;
    
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [img CGImage]);
    
    int tt = 1;
    CGFloat intensity;
    int bw;
    
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
            intensity = (rgbaPixel[tt] + rgbaPixel[tt + 1] + rgbaPixel[tt + 2]) / 3. / 255.;
            if (intensity > 0.45) {
                bw = 255;
            } else {
                bw = 0;
            }
            
            rgbaPixel[tt] = bw;
            rgbaPixel[tt + 1] = bw;
            rgbaPixel[tt + 2] = bw;
        }
    }
    
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CFRelease(pixels);
    
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image];
    
    // we're done with image now too
    CGImageRelease(image);
    return resultUIImage;
}

+ (UIImage *)scaleImage:(UIImage *)img toSize:(CGSize)size
{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage; 
}

+ (UIImage *)maskImage:(CGSize)size ridus:(CGFloat)radius {
    CAShapeLayer *pShapeLayer = [CAShapeLayer layer];
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    pShapeLayer.frame = rect;
    pShapeLayer.fillColor = [UIColor lightGrayColor].CGColor;
    
    UIBezierPath *pPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(size.width/2, size.height/2) radius:radius startAngle:0.0 endAngle:M_PI*2 clockwise:YES];
    pShapeLayer.path = pPath.CGPath;
    
    UIBezierPath *pOtherPath = [UIBezierPath bezierPathWithRect:rect];
    pShapeLayer.path = pOtherPath.CGPath;
    
    [pOtherPath appendPath:pPath];
    pShapeLayer.path = pOtherPath.CGPath;
    //重点
    pShapeLayer.fillRule = kCAFillRuleEvenOdd;

    return nil;
}

//双环模糊效果
+ (UIImage *)bluerImage:(UIImage *)image blurLevel:(NSInteger)blurVal center:(CGPoint)center radius:(CGFloat)radius offset:(CGFloat)offset {
    //高斯模糊滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    //将UIImage转换为CIImage类型
//    CVPixelBufferRef pixelBuffer = [self pixelBufferFromCGImage:image.CGImage];
//    CIImage *ciImage = [[CIImage alloc]initWithCVPixelBuffer:pixelBuffer];
    CIImage *ciImage = [[CIImage alloc]initWithImage:image];
    [filter setValue:ciImage forKey:kCIInputImageKey];
    //设置模糊程度
    [filter setValue:@(blurVal) forKey:kCIInputRadiusKey];//默认为10
    
    //径向渐变滤镜（同心圆）
    CIFilter *radialFilter = [CIFilter filterWithName:@"CIRadialGradient"];
    //图像像素为(1080,1920);
    //将圆点设置为人物头像位置，粗略估计为中心点偏上480
    [radialFilter setValue:[CIVector vectorWithX:center.x Y:center.y] forKey:@"inputCenter"];// 150 150
    //内圆半径
    [radialFilter setValue:@(radius) forKey:@"inputRadius0"]; //0 -- 800  5   inputColor0
    //外圆半径
    [radialFilter setValue:@(radius+offset) forKey:@"inputRadius1"];//  0 -- 800 100     inputColor1
    
//    NSLog(@"%@", radialFilter.attributes);
    //滤镜混合
    CIFilter *maskFilter = [CIFilter filterWithName:@"CIBlendWithMask"];
    //原图
    [maskFilter setValue:ciImage forKey:kCIInputImageKey];
    //高斯模糊处理后的图片
    [maskFilter setValue:filter.outputImage forKey:kCIInputBackgroundImageKey];
    //遮盖图片，这里为径向渐变所生成
    [maskFilter setValue:radialFilter.outputImage forKey:kCIInputMaskImageKey];
    EAGLContext *glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    CIContext *context = [CIContext contextWithEAGLContext:glContext];
    CGImageRef endImageRef = [context createCGImage:maskFilter.outputImage fromRect:ciImage.extent];
    UIImage *desImg = [UIImage imageWithCGImage:endImageRef];
    
    CGImageRelease(endImageRef);
//    CVPixelBufferRelease(pixelBuffer);
    return desImg;
}

//双线模糊效果
+ (UIImage *)bluerImage:(UIImage *)image blurLevel:(NSInteger)blurVal at:(CGPoint)center with:(CGFloat)with rotation:(CGFloat)angle {
    //将UIImage转换为CIImage类型
    CIImage *ciImage = [[CIImage alloc]initWithImage:image];
//    CVPixelBufferRef pixelBuffer = [self pixelBufferFromCGImage:image.CGImage];
//    CIImage *ciImage = [[CIImage alloc]initWithCVPixelBuffer:pixelBuffer];
    //高斯模糊滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:ciImage forKey:kCIInputImageKey];
    //设置模糊程度
    [filter setValue:@(blurVal) forKey:kCIInputRadiusKey];//默认为10
    
    CGFloat bluerLing = 100;
    CGPoint p1 = CGPointMake(center.x, center.y+with/2);
    CGPoint p2 = CGPointMake(center.x, center.y+with/2+bluerLing);
    CGPoint p3 = CGPointMake(center.x, center.y-with/2-bluerLing);
    CGPoint p4 = CGPointMake(center.x, center.y-with/2);
    angle = -angle;
    if (angle > 0.00001 || angle < -0.00001) {
        p1 = [self rotationPoint:p1 rotation:angle center:center];
        p2 = [self rotationPoint:p2 rotation:angle center:center];
        p3 = [self rotationPoint:p3 rotation:angle center:center];
        p4 = [self rotationPoint:p4 rotation:angle center:center];
    }
    
    //线性变化1
    CIFilter *linefilter = [CIFilter filterWithName:@"CILinearGradient"];
    [linefilter setValue:[CIVector vectorWithCGPoint:p1] forKey:@"inputPoint0"];
    [linefilter setValue:[CIVector vectorWithCGPoint:p2] forKey:@"inputPoint1"];
    
    //线性变化2
    CIFilter *linefilter2 = [CIFilter filterWithName:@"CILinearGradient"];
    [linefilter2 setValue:[CIVector vectorWithCGPoint:p3] forKey:@"inputPoint1"];
    [linefilter2 setValue:[CIVector vectorWithCGPoint:p4] forKey:@"inputPoint0"];
    
    //滤镜混合1
    CIFilter *maskFilter = [CIFilter filterWithName:@"CIBlendWithMask"];
    //原图
    [maskFilter setValue:ciImage forKey:kCIInputImageKey];
    //高斯模糊处理后的图片
    [maskFilter setValue:filter.outputImage forKey:kCIInputBackgroundImageKey];
    //遮盖图片，这里为径向渐变所生成
    [maskFilter setValue:linefilter.outputImage forKey:kCIInputMaskImageKey];
    
    
    //滤镜混合2
    CIFilter *maskFilter2 = [CIFilter filterWithName:@"CIBlendWithMask"];
    //原图
    [maskFilter2 setValue:maskFilter.outputImage forKey:kCIInputImageKey];
    //高斯模糊处理后的图片
    [maskFilter2 setValue:filter.outputImage forKey:kCIInputBackgroundImageKey];
    //遮盖图片，这里为径向渐变所生成
    [maskFilter2 setValue:linefilter2.outputImage forKey:kCIInputMaskImageKey];
    
    EAGLContext *glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    CIContext *context = [CIContext contextWithEAGLContext:glContext];
//    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef endImageRef = [context createCGImage:maskFilter2.outputImage fromRect:ciImage.extent];
    UIImage *desImg = [UIImage imageWithCGImage:endImageRef];
    
    CGImageRelease(endImageRef);
//    CVPixelBufferRelease(pixelBuffer);
    return desImg;
}

+ (CGPoint)rotationPoint:(CGPoint)point rotation:(CGFloat)angle {
    CGFloat sinVal = sin(angle);
    CGFloat cosVal = cos(angle);
    point = CGPointMake(point.x*cosVal-point.y*sinVal, point.y*cosVal+point.x*sinVal);
    return point;
}
+ (CGPoint)rotationPoint:(CGPoint)point rotation:(CGFloat)angle center:(CGPoint)rotationCenter{
    point = CGPointMake(point.x-rotationCenter.x, point.y-rotationCenter.y);
    CGFloat sinVal = sin(angle);
    CGFloat cosVal = cos(angle);
    point = CGPointMake(point.x*cosVal-point.y*sinVal+rotationCenter.x, point.y*cosVal+point.x*sinVal+rotationCenter.y);
    return point;
}
+ (UIImage *)vignetteImage:(UIImage *)img radius:(CGFloat)radius intensity:(CGFloat)val {
//0  2000   150       -1 1  1    inputFalloff :0 --1  0.5
    NSDictionary *par = @{kCIInputCenterKey:[CIVector vectorWithX:img.size.width/2 Y:img.size.height/2],kCIInputRadiusKey:@(radius), kCIInputIntensityKey:@(val)};
    CIImage *srcCIImg = [[CIImage alloc]initWithImage:img];
    CIFilter *fileter = [CIFilter filterWithName:@"CIVignetteEffect" withInputParameters:par];
    [fileter setValue:srcCIImg forKey:kCIInputImageKey];//kCIInputRadiusKey inputFalloff inputIntensity
    
    CIImage *grayCIImg = fileter.outputImage;
    
    //draw
    EAGLContext *glContext = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:glContext];
    CIContext *context = [CIContext contextWithEAGLContext:glContext];
    
    CGImageRef outputCGImg = [context createCGImage:grayCIImg fromRect:grayCIImg.extent];
    UIImage *desImg = [UIImage imageWithCGImage:outputCGImg];
    CGImageRelease(outputCGImg);
    return desImg;
}

+ (UIImage *)randomImage:(NSString *)path{
    UIImage *sample = [UIImage imageNamed:path];
    
    CGFloat width = arc4random_uniform(sample.size.width - 100) + 1 + 100;
    CGFloat height = arc4random_uniform(sample.size.height - 100) + 1 + 100;
    CGFloat x = arc4random_uniform(sample.size.width - width + 1);
    CGFloat y = arc4random_uniform(sample.size.height - height + 1);
    CGRect cropRect = CGRectMake(x, y, width, height);
    UIImage *cropped = [sample imageByCroppingRect:cropRect];
    return cropped;
}

+ (UIColor *)randomColor{
    CGFloat r = arc4random_uniform(255 + 1) / 255.0;
    CGFloat g = arc4random_uniform(255 + 1) / 255.0;
    CGFloat b = arc4random_uniform(255 + 1) / 255.0;
    return [UIColor colorWithRed:r green:g blue:b alpha:1];
}

+ (UIColor*)pixelColorAt:(CGPoint)point inImage:(UIImage *)image{
    
    UIColor* color = nil;
    CGImageRef inImage = image.CGImage;
    CGContextRef cgctx = [UIImage createARGBBitmapContextFromImage:
                          inImage];
    
    if (cgctx == NULL) { return nil; /* error */ }
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}};
    
    CGContextDrawImage(cgctx, rect, inImage);
    
    unsigned char* data = CGBitmapContextGetData (cgctx);
    
    if (data != NULL) {
        int offset = 4 * ((w * round(point.y)) + round(point.x));
        int alpha =  data[offset];
        int red = data[offset + 1];
        int green = data[offset + 2];
        int blue = data[offset + 3];
        NSLog(@"offset: %i colors: RGB A %i %i %i  %i",offset,red,green,blue,alpha);
        NSLog(@"x:%f y:%f", point.x, point.y);
        
        color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
    }
    
    CGContextRelease(cgctx);
    if (data) { CFRelease(data); }
    return color;
}

+ (CGContextRef)createARGBBitmapContextFromImage:(CGImageRef) inImage {
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if (colorSpace == NULL) {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    bitmapData = malloc( bitmapByteCount );
    
    if (bitmapData == NULL) {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);  
    
    if (context == NULL) {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }  
    
    CGColorSpaceRelease( colorSpace );
    return context;
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
+ (UIImage *)fixOrientation:(UIImage *)aImage {
    // No-op if the orientation is already correct
    if (aImage.imageOrientation ==UIImageOrientationUp)
        return aImage;
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform =CGAffineTransformIdentity;
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width,0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width,0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height,0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx =CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                            CGImageGetBitsPerComponent(aImage.CGImage),0,
                                            CGImageGetColorSpace(aImage.CGImage),
                                            CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx,CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
        default:
            CGContextDrawImage(ctx,CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg =CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
+ (UIImage *)leftRightMirror:(UIImage *)img {
    //Quartz重绘图片
    CGRect rect =  CGRectMake(0, 0, img.size.width , img.size.height);//创建矩形框
    //根据size大小创建一个基于位图的图形上下文
    UIGraphicsBeginImageContext(rect.size);
    //        UIGraphicsBeginImageContextWithOptions(rect.size, false, 2)
    CGContextRef currentContext = UIGraphicsGetCurrentContext();//获取当前quartz 2d绘图环境
    CGContextClipToRect(currentContext, rect);//设置当前绘图环境到矩形框
    CGContextRotateCTM(currentContext, M_PI); //旋转180度
    
    //平移， 这里是平移坐标系，跟平移图形是一个道理
    CGContextTranslateCTM(currentContext, -rect.size.width, -rect.size.height);
    CGContextDrawImage(currentContext, rect, img.CGImage);//绘图

    //翻转图片
    UIImage *drawImage =  UIGraphicsGetImageFromCurrentImageContext();//获得图片
    CGContextRelease(currentContext);
    return drawImage;
    
}
+ (UIImage *)upDownMirror:(UIImage *)img {
    //Quartz重绘图片
    CGRect rect =  CGRectMake(0, 0, img.size.width , img.size.height);//创建矩形框
    //根据size大小创建一个基于位图的图形上下文
    //    UIGraphicsBeginImageContext(rect.size);
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 2);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();//获取当前quartz 2d绘图环境
    CGContextClipToRect(currentContext, rect);//设置当前绘图环境到矩形框
    //    CGContextRotateCTM(currentContext, M_PI); //旋转180度
    
    //平移， 这里是平移坐标系，跟平移图形是一个道理
    //    CGContextTranslateCTM(currentContext, -rect.size.width, -rect.size.height);
    CGContextDrawImage(currentContext, rect, img.CGImage);//绘图
    
    //翻转图片
    UIImage *drawImage =  UIGraphicsGetImageFromCurrentImageContext();//获得图片
    CGContextRelease(currentContext);
    return drawImage;
    
}

+ (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation
{
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    
    switch (orientation) {
        case UIImageOrientationLeft:
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationRight:
            rotate = 3 * M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationDown:
            rotate = M_PI;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = 0;
            translateY = 0;
            break;
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    
    CGContextScaleCTM(context, scaleX, scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    
    CGContextRelease(context);
//    UIGraphicsEndImageContext();
    return newPic;
}

+ (UIImage*)rotateImageWithRadian:(CGFloat)radian img:(UIImage *)img cropMode:(EnSvCrop)cropMode
{
    CGSize imgSize = CGSizeMake(img.size.width * img.scale, img.size.height * img.scale);
    CGSize outputSize = imgSize;
    if (cropMode == EnSvCropExpand) {
        CGRect rect = CGRectMake(0, 0, imgSize.width, imgSize.height);
        rect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeRotation(radian));
        outputSize = CGSizeMake(CGRectGetWidth(rect), CGRectGetHeight(rect));
    }
    
    UIGraphicsBeginImageContext(outputSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, outputSize.width / 2, outputSize.height / 2);
    CGContextRotateCTM(context, radian);//以左上角为转轴旋转
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGRectMake(-imgSize.width/2, -imgSize.height/2, imgSize.width, imgSize.height), img.CGImage);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //CGContextRelease(context);
    return image;
}



//加文字
+ (UIImage*)addText:(UIImage *)img text:(NSString*)text1 {
    //getimage width and height
    NSInteger w = img.size.width;
    NSInteger h = img.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //createa graphic context with CGBitmapContextCreate
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 44 * w, colorSpace,kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context,CGRectMake(0, 0, w, h), img.CGImage);
    CGContextSetRGBFillColor(context,0.0, 1.0, 1.0, 1);
    char *text = (char *)[text1 cStringUsingEncoding:NSASCIIStringEncoding];
    CGContextSelectFont(context,"Georgia", 30, kCGEncodingMacRoman);
    
    //[text1 drawAtPoint:CGPointMake(w/2-strlen(text)*5, h/2) withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"OpenSans" size:12.0]}];
    
    CGContextSetTextDrawingMode(context,kCGTextFill);
    CGContextSetRGBFillColor(context,255, 0, 0, 1);
    CGContextShowTextAtPoint(context,w/2-strlen(text)*5, h/2, text, strlen(text));
    
    //Createimage ref from the context
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return[UIImage imageWithCGImage:imageMasked];
}

+ (UIImage*)addText:(UIImage *)img text:(NSString*)text at:(CGPoint)pt rotation:(CGFloat)angle scale:(CGFloat)scale attr:(NSDictionary *)attr {
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIGraphicsBeginImageContext(img.size);
//    CGContextSetCharacterSpacing (ctx, 1);  // 设置字符间距
//    CGContextSetRGBFillColor (ctx, 1, 0, 1, 1);  // 设置填充颜色
//    CGContextSetRGBStrokeColor (ctx, 0, 0, 1, 1);  // 设置线条颜色
//    CGContextSetTextDrawingMode (ctx, kCGTextFill);  // 设置使用填充模式绘制文字
    [img drawInRect:CGRectMake(0,0, img.size.width, img.size.height)];
    
    [text drawAtPoint:pt withAttributes:attr];
//    CGAffineTransform yRevert = CGAffineTransformMake(1, 0, 0, -1, 0, 0);
//    // 为yRevert变换矩阵根据scaleRate添加缩放变换矩阵
//    CGAffineTransform scaleTF = CGAffineTransformScale(yRevert, scale, scale);
//    // 为scale变换矩阵根据rotateAngle添加旋转变换矩阵
//    CGAffineTransform rotateTF = CGAffineTransformRotate(scaleTF, M_PI / 3);
//    CGContextSetTextMatrix(ctx, rotateTF);  // 对CGContextRef绘制文字时应用变换
////    [text drawAtPoint:pt withAttributes:attr];
//    CGContextShowTextAtPoint(ctx, pt.x, pt.y, "crazyit.org", 11);
    
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


//加图片
+ (UIImage*)addImageLogo:(UIImage *)img text:(UIImage*)logo {
    //getimage width and height
    NSInteger w = img.size.width;
    NSInteger h = img.size.height;
    NSInteger logoWidth = logo.size.width;
    NSInteger logoHeight = logo.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //createa graphic context with CGBitmapContextCreate
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 44 * w, colorSpace,kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context,CGRectMake(0, 0, w, h), img.CGImage);
    CGContextDrawImage(context,CGRectMake(w-logoWidth, 0, logoWidth, logoHeight), [logo CGImage]);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return[UIImage imageWithCGImage:imageMasked];
    // CGContextDrawImage(contextRef,CGRectMake(100, 50, 200, 80), [smallImgCGImage]);
}

//加半透明的水印
+ (UIImage*)addImage:(UIImage *)useImage addImage1:(UIImage*)addImage1 {
    UIGraphicsBeginImageContext(useImage.size);
    [useImage drawInRect:CGRectMake(0, 0, useImage.size.width,useImage.size.height)];
    [addImage1 drawInRect:CGRectMake(0,useImage.size.height-addImage1.size.height, addImage1.size.width,addImage1.size.height)];
    UIImage*resultingImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

+ (UIImage *)captureScrollView:(UIScrollView *)scrollView {
    UIImage* image =nil;
    UIGraphicsBeginImageContextWithOptions(scrollView.contentSize,NO,0.0);
    {
        CGPoint savedContentOffset = scrollView.contentOffset;
        CGRect savedFrame = scrollView.frame;
        scrollView.contentOffset= CGPointZero;
        scrollView.frame= CGRectMake(0, 0, scrollView.contentSize.width,scrollView.contentSize.height);
        
        [scrollView.layer renderInContext: UIGraphicsGetCurrentContext()];
        image= UIGraphicsGetImageFromCurrentImageContext();
        
        scrollView.contentOffset= savedContentOffset;
        scrollView.frame= savedFrame;
    }
    UIGraphicsEndImageContext();
    
    if(image != nil) {
        return image;
    }
    return nil;
}


+ (CVPixelBufferRef)pixelBufferFromCGImage: (CGImageRef)image {
    NSDictionary *options = @{(NSString*)kCVPixelBufferCGImageCompatibilityKey : @YES,
                              (NSString*)kCVPixelBufferCGBitmapContextCompatibilityKey : @YES,
                              };
    
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, CGImageGetWidth(image),
                                          CGImageGetHeight(image), kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    if (status != kCVReturnSuccess) {
        NSLog(@"Operation failed");
    }
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, CGImageGetWidth(image),
                                                 CGImageGetHeight(image), 8, 4*CGImageGetWidth(image), rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    
    //    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    //    CGAffineTransform flipVertical = CGAffineTransformMake( 1, 0, 0, -1, 0, CGImageGetHeight(image) );
    //    CGContextConcatCTM(context, flipVertical);
    //    CGAffineTransform flipHorizontal = CGAffineTransformMake( -1.0, 0.0, 0.0, 1.0, CGImageGetWidth(image), 0.0 );
    //    CGContextConcatCTM(context, flipHorizontal);
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    return pxbuffer;
}
@end
