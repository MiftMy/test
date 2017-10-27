//
//  APCutMaskView.m
//  test
//
//  Created by mifit on 2017/9/29.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import "APCutMaskView.h"
#import "APCutFrameView.h"
#import "Masonry.h"

@interface APCutMaskView()
{
    //mask
    UIView *maskLeftView;
    UIView *maskRightView;
    UIView *maskTopView;
    UIView *maskBottomView;
    
    //显示裁剪框
    APCutFrameView *showView;
    CGRect maxCutRect;
    
    
    
    //手势
    CGPoint touchBeginPt;//手势触摸点
    CGRect touchBeginRect;//裁剪框
}
@end
@implementation APCutMaskView

- (APCutMaskView *)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        [self setupData];
        [self setupUI];
        [self setupGesture];
    }
    return self;
}

- (void)layoutSubviews {
    if (CGRectEqualToRect(maxCutRect, CGRectZero)) {
        maxCutRect = CGRectInset(self.bounds, 25, 25);
        if (CGRectEqualToRect(_showRect, CGRectZero)) {
            _showRect = maxCutRect;
        }
        [self layoutMakeRect:self.showRect];
    }
}
//手势除了出发点，其他全部穿透给下层
- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event {
    point.x -= showView.frame.origin.x;
    point.y -= showView.frame.origin.y;
    APGRActiveType type = [showView checkActive:point];
    showView.activeType = type;
    return type > 0;
}
#pragma mark - public
- (void)setWhRate:(CGFloat)whRate {
    if (_whRate != whRate) {
        _whRate = whRate;
        CGRect rect = [self scaleNormalRect:self.imgRectInIV];
        
        self.showRect = rect;
    }
}
- (void)setImgSize:(CGSize)imgSize {
    if (!CGSizeEqualToSize(imgSize, _imgSize)) {
        _imgSize = imgSize;
    }
}
- (void)setShowRect:(CGRect)showRect {
    _showRect = showRect;
    if (!CGRectEqualToRect(maxCutRect, CGRectZero)) {
        showRect = [self scaleNormalRect:showRect];
        [self layoutUpdateRect:showRect];
    }
}

#pragma mark - private
- (void)setupData {
    maxCutRect = CGRectZero;
    _showRect = CGRectZero;
}

- (void)setupUI {
    for (NSInteger indx = 0; indx < 4; indx ++) {
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor blackColor];
        view.alpha = 0.5;
        [self addSubview:view];
        if (indx == 0) {
            maskLeftView = view;
        }
        if (indx == 1) {
            maskRightView = view;
        }
        if (indx == 2) {
            maskTopView = view;
        }
        if (indx == 3) {
            maskBottomView = view;
        }
    }
    showView = [APCutFrameView new];
    showView.isShowGrid = NO;
    [self addSubview:showView];
}

//rect为显示的裁剪框rect，而不是承载裁剪框的view的frame
- (void)layoutMakeRect:(CGRect)rect {
    CGPoint point = rect.origin;
    CGSize size = rect.size;
    CGSize maxSize = self.bounds.size;
    CGFloat len = showView.activeLen/2;
    //超范围处理，限制在view显示内
    if (point.x < 0) {
        CGFloat space = 0 - point.x;
        point.x = 0;
        size.width -= space;
    }
    if (point.y < 0) {
        CGFloat space = 0 - point.y;
        point.y = 0;
        size.height -= space;
    }
    if (point.x+size.width > maxSize.width) {
        size.width = maxSize.width - point.x;
    }
    if (point.y+size.height > maxSize.height) {
        size.height = maxSize.height - point.y;
    }
    
    CGFloat lenX = point.x;
    CGFloat lenY = point.y;
    
    [maskTopView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.top.equalTo(self.mas_top);
        make.height.mas_equalTo(lenY);
    }];
    
    CGFloat y = point.y + size.height;
    [maskBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.bottom.equalTo(self.mas_bottom);
        make.height.mas_equalTo(maxSize.height-y);
    }];
    
    [maskLeftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.top.equalTo(maskTopView.mas_bottom);
        make.bottom.equalTo(maskBottomView.mas_top);
        make.width.mas_equalTo(lenX);
    }];
    
    CGFloat x = size.width+lenX;
    [maskRightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right);
        make.top.equalTo(maskTopView.mas_bottom);
        make.bottom.equalTo(maskBottomView.mas_top);
        make.width.mas_equalTo(maxSize.width-x);
    }];
    
    CGFloat r = maxSize.width - size.width - (lenX+len);
    CGFloat b = maxSize.height - size.height - (lenY + len);
    [showView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(lenY-len);
        make.right.equalTo(self.mas_right).offset(-r);
        make.bottom.equalTo(self.mas_bottom).offset(-b);
        make.left.equalTo(self.mas_left).offset(lenX-len);
    }];
}

//rect为裁剪框显示的rect，不是承载裁剪框的view的frame
- (void)layoutUpdateRect:(CGRect)rect {
    CGPoint point = rect.origin;
    CGSize maxSize = self.frame.size;
    CGSize size = rect.size;
    CGFloat len = showView.activeLen/2;
    
    //超范围处理，限制在view显示内
    if (point.x < 0) {
        CGFloat space = 0 - point.x;
        point.x = 0;
        size.width -= space;
    }
    if (point.y < 0) {
        CGFloat space = 0 - point.y;
        point.y = 0;
        size.height -= space;
    }
    if (point.x+size.width > maxSize.width) {
        size.width = maxSize.width - point.x;
    }
    if (point.y+size.height > maxSize.height) {
        size.height = maxSize.height - point.y;
    }
    CGFloat lenX = point.x;
    CGFloat lenY = point.y;
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    [maskTopView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.top.equalTo(self.mas_top);
        make.height.mas_equalTo(lenY);
    }];
    
    CGFloat y = point.y + size.height;
    [maskBottomView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.bottom.equalTo(self.mas_bottom);
        make.height.mas_equalTo(height-y);
    }];
    
    [maskLeftView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.top.equalTo(maskTopView.mas_bottom);
        make.bottom.equalTo(maskBottomView.mas_top);
        make.width.mas_equalTo(lenX);
    }];
    
    CGFloat x = size.width+lenX;
    [maskRightView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right);
        make.top.equalTo(maskTopView.mas_bottom);
        make.bottom.equalTo(maskBottomView.mas_top);
        make.width.mas_equalTo(width-x);
    }];
    
    CGFloat r = maxSize.width - size.width - (lenX+len);
    CGFloat b = maxSize.height - size.height - (lenY + len);
    [showView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(lenY-len);
        make.right.equalTo(self.mas_right).offset(-r);
        make.bottom.equalTo(self.mas_bottom).offset(-b);
        make.left.equalTo(self.mas_left).offset(lenX-len);
    }];
}

- (void)updateSizeText:(CGRect)rect {
    CGFloat scale = self.scScale;
    CGSize s = self.imgRectInIV.size;
    s.width *= scale;s.height *= scale;
    CGFloat w = rect.size.width / s.width * self.imgSize.width;
    CGFloat h = rect.size.height / s.height * self.imgSize.height;
    showView.imgSize = CGSizeMake(w, h);
}

#pragma mark gesture
- (void)setupGesture {
    UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGRHandle:)];
    [self addGestureRecognizer:panGR];
}

- (void)panGRHandle:(UIPanGestureRecognizer *)panGr {
    CGPoint point = [panGr locationInView:self];
    if (panGr.state == UIGestureRecognizerStateBegan) {
        touchBeginPt = point;
        showView.isShowGrid = YES;
        touchBeginRect = showView.frame;
    }
    
    if (panGr.state == UIGestureRecognizerStateChanged || panGr.state == UIGestureRecognizerStateEnded) {
        CGSize offset = CGSizeMake(point.x-touchBeginPt.x, point.y-touchBeginPt.y);
        //裁剪框内陷activeLen/2
        CGRect temFrame = touchBeginRect;
        CGFloat insetLen = showView.activeLen/2;
        temFrame = CGRectInset(temFrame, insetLen, insetLen);
        CGRect temRect = [self dealWithRect:temFrame offset:offset];
        temRect = [self fixMinRect:temRect];//最小限制
        temRect = [self scaleRect:temRect];//比例裁剪框
        
        if (panGr.state != UIGestureRecognizerStateEnded) {
            self.showRect = temRect;
            [self updateSizeText:temRect];
            [self setNeedsDisplay];
        } else {
            [UIView animateWithDuration:0.5 animations:^{
                //缩放到maxCutRect内最大
                CGRect desRect = [self scaleBackCurFrame:temRect];
                self.showRect = desRect;
                [self layoutIfNeeded];
            } completion:^(BOOL finished) {
                showView.isShowGrid = NO;
            }];
        }
    }
}

#pragma mark cut frame
//不同出发点处理offset
- (CGRect)dealWithRect:(CGRect)rect offset:(CGSize)size {
    //结果rect
    CGRect rectDes = rect;
    //自由对应的rect
    switch (showView.activeType) {
        case APGRActiveTypeTopLeft:
            rectDes.origin.x += size.width;
            rectDes.origin.y += size.height;
            rectDes.size.width -= size.width;
            rectDes.size.height -= size.height;
            break;
        case APGRActiveTypeTopRight:
            rectDes.origin.y += size.height;
            rectDes.size.width += size.width;
            rectDes.size.height -= size.height;
            break;
        case APGRActiveTypeBottomRight:
            rectDes.size.width += size.width;
            rectDes.size.height += size.height;
            break;
        case APGRActiveTypeBottomLeft:
            rectDes.origin.x += size.width;
            rectDes.size.width -= size.width;
            rectDes.size.height += size.height;
            break;
        case APGRActiveTypeTopMid:
            rectDes.origin.y += size.height;
            rectDes.size.height -= size.height;
            break;
        case APGRActiveTypeRightMid:
            rectDes.size.width += size.width;
            break;
        case APGRActiveTypeBottomMid:
            rectDes.size.height += size.height;
            break;
        case APGRActiveTypeLeftMid:
            rectDes.origin.x += size.width;
            rectDes.size.width -= size.width;
            break;
        default:
            break;
    }
    return rectDes;
}
//移动裁剪框时候，修正rect，保证最小rec和不超出图片
- (CGRect)fixMinRect:(CGRect)rect {
    CGFloat activeWith = showView.activeLen;
    if (rect.size.width < 2*activeWith) {//宽超最小限制了
        switch (showView.activeType) {
            case APGRActiveTypeTopLeft:
            case APGRActiveTypeBottomLeft:
            case APGRActiveTypeLeftMid:
            {
                CGFloat offset = 2*activeWith - rect.size.width;
                rect.size.width = 2*activeWith;
                rect.origin.x -= offset;
            }
                break;
            case APGRActiveTypeTopRight:
            case APGRActiveTypeBottomRight:
            case APGRActiveTypeRightMid:
            {
                rect.size.width = 2*activeWith;
            }
                break;
            default:
                break;
        }
        
    }
    if (rect.size.height < 2*activeWith) {//高超最小限制了
        switch (showView.activeType) {
            case APGRActiveTypeTopLeft:
            case APGRActiveTypeTopRight:
            case APGRActiveTypeTopMid:
            {
                CGFloat offset = 2*activeWith - rect.size.height;
                rect.size.height = 2*activeWith;
                rect.origin.y -= offset;
            }
                break;
            case APGRActiveTypeBottomRight:
            case APGRActiveTypeBottomLeft:
            case APGRActiveTypeBottomMid:
                rect.size.height = 2*activeWith;
                break;
            default:
                break;
        }
    }
    //    if (CGRectIntersectsRect(imgRectInIV, rect)) {// rect 超出图片rect
    //        if (rect.origin.x < imgRectInIV.origin.x) {
    //            CGFloat offsetX = rect.origin.x - imgRectInIV.origin.x;
    //            rect.origin.x = imgRectInIV.origin.x;
    //            rect.size.width -= offsetX;
    //        }
    //        if (rect.origin.y < imgRectInIV.origin.y) {
    //            CGFloat offsetY = rect.origin.y - imgRectInIV.origin.y;
    //            rect.origin.y = imgRectInIV.origin.y;
    //            rect.size.height -= offsetY;
    //        }
    //        if (rect.origin.x+rect.size.width > imgRectInIV.origin.x+imgRectInIV.size.width) {
    //            rect.size.width = imgRectInIV.origin.x+imgRectInIV.size.width - rect.origin.x;
    //        }
    //        if (rect.origin.y+rect.size.height > imgRectInIV.origin.y+imgRectInIV.size.height) {
    //            rect.size.height = imgRectInIV.origin.y+imgRectInIV.size.height - rect.origin.y;
    //        }
    //    }
    return rect;
}

- (CGRect)scaleNormalRect:(CGRect)rect {
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
    }
    return rectDes;
}

//不同方向上，缩放rect
- (CGRect)scaleRect:(CGRect)rect {
    CGRect rectDes = rect;
    //比例
    if (self.whRate > 0) {
        CGFloat temW = rectDes.size.height * self.whRate;
        if (rectDes.size.width > temW) {
            switch (showView.activeType) {
                case APGRActiveTypeTopLeft:
                case APGRActiveTypeBottomLeft:
                case APGRActiveTypeLeftMid:
                    rectDes.origin.x += rectDes.size.width - temW;
                    rectDes.size.width = temW;
                    break;
                case APGRActiveTypeTopRight:
                case APGRActiveTypeBottomRight:
                case APGRActiveTypeTopMid:
                case APGRActiveTypeRightMid:
                case APGRActiveTypeBottomMid:
                    rectDes.size.width = temW;
                    break;
            }
            
        } else {
            CGFloat temH = rect.size.width / self.whRate;;
            switch (showView.activeType) {
                case APGRActiveTypeTopLeft:
                case APGRActiveTypeTopRight:
                case APGRActiveTypeTopMid:
                case APGRActiveTypeLeftMid:
                    rectDes.origin.y += rectDes.size.height - temH;
                    rectDes.size.height = temH;
                    break;
                case APGRActiveTypeBottomRight:
                case APGRActiveTypeBottomLeft:
                case APGRActiveTypeRightMid:
                case APGRActiveTypeBottomMid:
                    rectDes.size.height = temH;
                    break;
                default:
                    break;
            }
        }
    }
    return rectDes;
}

//裁剪框恢复最大， rect为当前裁剪框位置大小
- (CGRect)scaleBackCurFrame:(CGRect)rect {
    CGSize maxSize = maxCutRect.size;
    CGFloat scaleW = maxSize.width / rect.size.width;
    CGFloat scaleH = maxSize.height / rect.size.height;
    CGFloat scale = scaleW;
    ///一般
    if (scaleH < scaleW) {
        scale = scaleH;
    }
    
    CGRect tem = rect;
    tem.size.width *= scale;
    tem.size.height *= scale;
    CGFloat temX = (maxSize.width - tem.size.width)/2;
    CGFloat temY = (maxSize.height - tem.size.height)/2;
    tem.origin = CGPointMake(temX, temY);
    tem.origin.x += maxCutRect.origin.x;
    tem.origin.y += maxCutRect.origin.y;
    if (self.zoomScale) {
        self.zoomScale(scale, rect, tem);
    }
    return tem;
}
@end
