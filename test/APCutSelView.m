//
//  APCutSelView.m
//  test
//
//  Created by mifit on 2017/9/29.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import "APCutSelView.h"
#import "APCutFrameView.h"
#import "APCutMaskView.h"
#import "XMTool.h"
#import "UIImage_XMImage.h"
@interface APCutSelView()
<UIScrollViewDelegate>
{
    //scrollview 包含imgview，缩放imgview
    UIScrollView *scrollview;
    UIImageView *imgView;
    CGFloat ivMinInset;//imageview在scrollview内最小inset
    
    //图片在imageview内的位置大小
    CGRect orgImgRectInIV;
    
    APCutMaskView *maskView;
    
    //缩放最小最大倍数
    CGFloat minScale;
    CGFloat maxScale;
    CGFloat lastScale;
    
    BOOL isLayout;
    //
    UIView *view;
    UIScrollView *temScrl;
}
@property (nonatomic, assign) CGRect cutRect;//裁剪框rect
@property (nonatomic, assign) CGFloat scale;//缩放倍数
@end

@implementation APCutSelView
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupData];
    [self setupUI];
}

- (APCutSelView *)init {
    if (self = [super init]) {
        [self setupData];
        [self setupUI];
    }
    return self;
}
- (void)layoutSubviews {
    if (CGRectEqualToRect(_cutRect, CGRectZero) || !isLayout) {
        isLayout = YES;
        [self defaultLayoutViews];
    }
}

#pragma mark - public
- (void)setWhRate:(CGFloat)whRate {
    if (_whRate != whRate) {
        _whRate = whRate;
        maskView.whRate = whRate;
        if (isLayout) {
            [self defaultLayoutViews];
        }
    }
}
- (void)setOrgImg:(UIImage *)orgImg {
    if (_orgImg != orgImg) {
        _orgImg = orgImg;
        imgView.image = orgImg;
        if (isLayout) {
            [self defaultLayoutViews];
        }
    }
}

//重要方法！
- (void)setRotationAngle:(CGFloat)rotationAngle {
    _rotationAngle = rotationAngle;
    
    //裁剪框的四个顶点
    CGRect orgRect = self.cutRect;
    CGPoint lt = orgRect.origin;
    CGPoint rt = lt;
    rt.x += orgRect.size.width;
    CGPoint lb = lt;
    lb.y += orgRect.size.height;
    CGPoint rb = lb;
    rb.x = rt.x;
    CGFloat midX = CGRectGetMidX(orgRect);
    CGFloat midY = CGRectGetMidY(orgRect);
    CGPoint center = CGPointMake(midX, midY);
    //旋转后的坐标
    CGPoint dLt = [XMTool rotationPoint:lt atCenter:center angle:rotationAngle];
    CGPoint dRt = [XMTool rotationPoint:rt atCenter:center angle:rotationAngle];
    CGPoint dLb = [XMTool rotationPoint:lb atCenter:center angle:rotationAngle];
    CGPoint dRb = [XMTool rotationPoint:rb atCenter:center angle:rotationAngle];
    
    //最大最小x、y
    CGFloat maxX = 0, maxY = 0;
    CGFloat minX = 0, minY = 0;
    maxX = MAX(dRb.x, dRt.x);
    maxY = MAX(dLb.y, dRb.y);
    minX = MIN(dLb.x, dLt.x);
    minY = MIN(dRt.y, dLt.y);
    //满足这个宽高就可以包含裁剪框。
    CGFloat width = maxX - minX;
    CGFloat height = maxY - minY;
    
    CGSize imgSize = orgImgRectInIV.size;
    CGFloat sW = width / imgSize.width;
    CGFloat sH = height / imgSize.height;
    CGFloat scale = sW;
    if (sW < sH) {
        scale = sH;
    }
    CGAffineTransform tf = CGAffineTransformMakeRotation(rotationAngle);
    scrollview.transform = tf;
    if (scrollview.zoomScale < scale) {
        scrollview.zoomScale = scale;
        maskView.scScale = scale;
        _scale = scale;
    }
    scrollview.minimumZoomScale = scale;
    minScale = scale;
    
    //设置上下左右不超出图片。  即裁剪框的上下左右的顶点到旋转后scrollview的边的距离即为图片到scrollview的距离。缩放是必要的，缩放最小倍数是最小容纳裁剪框的。
    CGSize bgSize = self.bounds.size;
    CGPoint bgLT = CGPointZero;
    CGPoint bgLB = CGPointMake(0, bgSize.height);
    CGPoint bgRT = CGPointMake(bgSize.width, 0);
    CGPoint dBGLT = [XMTool rotationPoint:bgLT atCenter:center angle:rotationAngle];
    CGPoint dBGLB = [XMTool rotationPoint:bgLB atCenter:center angle:rotationAngle];
    CGPoint dBGRT = [XMTool rotationPoint:bgRT atCenter:center angle:rotationAngle];
    CGFloat desX = 0;
    CGFloat desY = 0;
    
    if (rotationAngle > 0) {
        desX = [XMTool distanceFromPt:lt toPt:dBGLT andPt:dBGLB];
        desY = [XMTool distanceFromPt:rt toPt:dBGLT andPt:dBGRT];
        NSInteger val = [XMTool pointPosition:lt atPoint:dBGLT to:dBGLB];
        if (val > 0 ) {
            desX = -desX;
        }
        NSInteger val2 = [XMTool pointPosition:rt atPoint:dBGLT to:dBGRT];
        if ((val2 < 0) ) {
            desY = -desY;
        }
    }
    if (rotationAngle <= 0) {
        desX = [XMTool distanceFromPt:lb toPt:dBGLT andPt:dBGLB];
        desY = [XMTool distanceFromPt:lt toPt:dBGLT andPt:dBGRT];
        NSInteger val = [XMTool pointPosition:lb atPoint:dBGLT to:dBGLB];
        if ( val > 0 ) {
            desX = -desX;
        }
        NSInteger val2 = [XMTool pointPosition:rt atPoint:dBGLT to:dBGRT];
        if (val2 < 0 ) {
            desY = -desY;
        }
    }
    CGRect imgFrame = imgView.frame;
    imgFrame.origin = CGPointMake(desX, desY);
    imgView.frame = imgFrame;
    CGSize ts = imgFrame.size;
    ts.width += desX*2;
    ts.height += desY*2;
    scrollview.contentSize = ts;
}


- (void)imageFromCurrent:(void (^)(UIImage *img))block {
    if (block) {
        self.transform = CGAffineTransformMakeRotation(0);
        
        UIImage *img = [UIImage rotateImageWithRadian:self.rotationAngle img:self.orgImg cropMode:EnSvCropExpand];
        
        //原图大小
        CGSize orgSize = self.orgImg.size;
        //原图旋转后大小
        CGSize imgRotationSize = img.size;
        
        //imageview内的大小
        CGSize ivSize = orgImgRectInIV.size;
        CGFloat rW = ivSize.width / orgSize.width * imgRotationSize.width;
        CGFloat rH = ivSize.height / orgSize.height * imgRotationSize.height;
        //imageview内旋转的大小
        CGSize ivRotationSize = CGSizeMake(rW, rH);
        
        //scrollview的zoomScale
        CGFloat zscale = scrollview.zoomScale;
        
        //imageview内旋转缩放的大小
        CGSize ivDesSize = CGSizeMake(ivRotationSize.width*zscale, ivRotationSize.height*zscale);
        
        //cutRect
        CGSize cutSize = self.cutRect.size;
        //scrollview 未偏移时候，cutRect在scrollview的位置，即中心重合时候的rect
        CGRect ivCutRect = CGRectMake((ivDesSize.width-cutSize.width)/2, (ivDesSize.height-cutSize.height)/2, cutSize.width, cutSize.height);
        
        //中心位置对应的offset
        CGSize ctSize = scrollview.contentSize;
        CGSize scSize = self.frame.size;
        CGPoint centerOffset = CGPointMake((ctSize.width-scSize.width)/2, (ctSize.height-scSize.height)/2);
        
        //计算offset偏移中心多少
        CGPoint ctOffset = scrollview.contentOffset;
        CGPoint offset = CGPointMake(ctOffset.x-centerOffset.x, ctOffset.y-centerOffset.y);
        //坐标系不一致
        offset = [XMTool rotationPoint:offset atCenter:CGPointZero angle:self.rotationAngle];
        
        //偏移后cutrect对应的rect
        CGPoint org = ivCutRect.origin;
        org.x += offset.x;
        org.y += offset.y;
        CGRect desRect = ivCutRect;
        desRect.origin = org;
        
        CGFloat scale = imgRotationSize.width / ivDesSize.width;
        desRect.origin.x *= scale;
        desRect.origin.y *= scale;
        desRect.size.width *= scale;
        desRect.size.height *= scale;
        UIImage *desImg = [img imageByCroppingRect:desRect];
        
        desImg = [UIImage rotateImageWithRadian:self.angle img:desImg cropMode:EnSvCropClip];
        self.transform = CGAffineTransformMakeRotation(self.angle);
        block(desImg);
    }
}
#pragma mark - private

- (void)setupData {
    minScale = 1;
    maxScale = 5;
    lastScale = 1;
    _scale = 1;
    _cutRect = CGRectZero;
    ivMinInset = 25;
    self.clipsToBounds = YES;
}

- (void)setupUI {
    scrollview = [[UIScrollView alloc]init];
    scrollview.delegate = self;
    scrollview.bouncesZoom = YES;
    scrollview.backgroundColor = [UIColor clearColor];
    scrollview.alwaysBounceVertical = YES;
    scrollview.alwaysBounceHorizontal = YES;
    scrollview.showsVerticalScrollIndicator = NO;
    scrollview.showsHorizontalScrollIndicator = NO;
    scrollview.clipsToBounds = NO;
    
    scrollview.minimumZoomScale = minScale;
    scrollview.maximumZoomScale = maxScale;
    [self addSubview:scrollview];
    
    imgView = [UIImageView new];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    imgView.backgroundColor = [UIColor clearColor];
    [scrollview addSubview:imgView];
    
    __weak typeof(self) weakSelf = self;
    maskView = [APCutMaskView new];
    maskView.scScale = 1;
    [self addSubview:maskView];
    maskView.zoomScale = ^(CGFloat scale, CGRect fRect, CGRect tRect) {
        __strong typeof(self) wsSelf = weakSelf;
        wsSelf.cutRect = tRect;
        [wsSelf ivMoveImgFrom:fRect to:tRect scale:scale];
    };

}

- (void)defaultLayoutViews {
    //恢复旋转角度
    CGAffineTransform tf = CGAffineTransformMakeRotation(0);
    scrollview.transform = tf;
    _rotationAngle = 0;
    
    //缩放倍数
    minScale = 1;
    scrollview.minimumZoomScale = minScale;
    scrollview.maximumZoomScale = maxScale;
    scrollview.zoomScale = minScale;
    maskView.scScale = minScale;
    
    //图片大小
    CGSize imgSize = self.orgImg.size;
    maskView.imgSize = imgSize;
    
    scrollview.frame = self.bounds;
    
    //能显示图片的最大size
    CGRect maxRect = CGRectInset(self.bounds, ivMinInset, ivMinInset);
    CGSize ivSize = maxRect.size;
    
    //image显示在最大size里面显示的size
    CGFloat sW = imgSize.width / ivSize.width;
    CGFloat sH = imgSize.height / ivSize.height;
    CGSize temSize = imgSize;
    CGFloat scale = sW;
    if (sW < sH) {
        scale = sH;
    }
    temSize.width /= scale;
    temSize.height /= scale;
    orgImgRectInIV = CGRectMake((ivSize.width-temSize.width)/2, (ivSize.height-temSize.height)/2, temSize.width, temSize.height);
    
    //裁剪框rect
    CGRect rect = maxRect;
    rect = [self rateDefaultRect: maxRect];
    self.cutRect = rect;
    
    CGRect imgFrame = orgImgRectInIV;
    imgFrame.origin.x += 25;
    imgFrame.origin.y += 25;
    if (self.whRate > 0) {
        imgFrame.origin = rect.origin;
        imgView.frame = imgFrame;
        CGFloat ssc = rect.size.height / orgImgRectInIV.size.height;
        CGFloat s1 = rect.size.height / rect.size.width;
        CGFloat s2 = orgImgRectInIV.size.height / orgImgRectInIV.size.width;
        if (s1 < s2 ) {
            ssc = rect.size.width / orgImgRectInIV.size.width;
        }
        scrollview.zoomScale = ssc;
    } else {
        imgView.frame = imgFrame;
    }
    CGRect rr = imgView.frame;
    CGSize ctSize = CGSizeMake(rr.size.width+2*rr.origin.x, rr.size.height+2*rr.origin.y);
    scrollview.contentSize = ctSize;
    CGPoint ofs = CGPointMake((rr.size.width-rect.size.width)/2, (rr.size.height-rect.size.height)/2);
    scrollview.contentOffset = ofs;
    
    maskView.imgRectInIV = orgImgRectInIV;
    maskView.frame = self.bounds;
    maskView.showRect = rect;
    
}
- (CGRect)rateDefaultRect:(CGRect)rect {
    CGRect rectDes = rect;
    if (self.whRate > 0) {
        CGFloat s = rect.size.width / rect.size.height;
        if (s < self.whRate) {
            rectDes.size.height = rect.size.width / self.whRate;
            rectDes.origin.y += (rect.size.height - rectDes.size.height)/2;
        } else {
            rectDes.size.width = rect.size.height * self.whRate;
            rectDes.origin.x += (rect.size.width - rectDes.size.width)/2;
        }
    } else {
        rectDes.origin.x += orgImgRectInIV.origin.x;
        rectDes.origin.y += orgImgRectInIV.origin.y;
        rectDes.size = orgImgRectInIV.size;
    }
    return rectDes;
}
//缩放平移imageview从某位置到指定位置居中。两个rect宽高正比,即scale
- (void)ivMoveImgFrom:(CGRect)fRect to:(CGRect)tRect scale:(CGFloat)scale {
    CGPoint offset = scrollview.contentOffset;
    CGPoint ivPosition = imgView.frame.origin;

    //缩放图片
    CGFloat dSacle = scrollview.zoomScale * scale;
    if (dSacle > maxScale) {
        CGFloat space = dSacle - maxScale;
        CGFloat ds = space / scrollview.zoomScale;
        dSacle = maxScale;
        scale -= ds;
    }
    if (dSacle < minScale) {
        CGFloat space = dSacle - minScale;
        CGFloat ds = space / scrollview.zoomScale;
        dSacle = minScale;
        scale -= ds;
    }
    scrollview.zoomScale *= scale;
    _scale = scrollview.zoomScale;
    maskView.scScale = _scale;
    
    //调整图片使裁剪框不超图图片范围。
    self.rotationAngle = self.rotationAngle;
    CGRect temF = fRect;
    if (temF.origin.x < 25) {
        temF.origin.x = 25;
    }
    if (temF.origin.y < 25) {
        temF.origin.y = 25;
    }
    
    CGFloat midX = CGRectGetMidX(self.bounds);
    CGFloat midY = CGRectGetMidY(self.bounds);
    CGPoint center = CGPointMake(midX, midY);
    CGPoint t = temF.origin;
    //裁剪框松手前的左上角坐标，从基view的坐标系转为scrollview上坐标系
    CGPoint tt = [XMTool point:t rotationCoordinateAtCenter:center angle:self.rotationAngle];
    
    //裁剪框左上角的点对应图片位置
    CGPoint fRectPtInImgPt = CGPointMake(tt.x+offset.x-ivPosition.x, tt.y+offset.y-ivPosition.y);
    //缩放后的位置
    fRectPtInImgPt.x *= scale;
    fRectPtInImgPt.y *= scale;

    //蒙对的。不知道为什么要减，不减时候，运行发现就多了这个距离。
    fRectPtInImgPt.y -= self.cutRect.size.width*sin(self.rotationAngle)*cos(self.rotationAngle);
    //这时候要把fRectPtInImgPt，显示在scrollview的0，0点。
    scrollview.contentOffset = fRectPtInImgPt;
    
    self.rotationAngle = self.rotationAngle;
    CGPoint ttttt = scrollview.contentOffset;
    if (ttttt.y < 0 ) {
        ttttt.y = 0;
        scrollview.contentOffset= ttttt;
    }
    if (ttttt.x < 0 ) {
        ttttt.x = 0;
        scrollview.contentOffset= ttttt;
    }
}

#pragma mark - scrollview delegate
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (scrollView == scrollview) {
        return imgView;
    }
    return view;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    CGFloat w = orgImgRectInIV.size.width * scale;
    CGFloat h = orgImgRectInIV.size.height * scale;
    CGPoint org = imgView.frame.origin;
    scrollview.contentSize = CGSizeMake(w + 2*org.x, h + 2*org.y);
}
@end
