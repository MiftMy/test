//
//  APCutFrameView.m
//  test
//
//  Created by mifit on 2017/9/29.
//  Copyright © 2017年 Mifit. All rights reserved.
//

#import "APCutFrameView.h"
#import "Masonry.h"



@interface APCutFrameView()
{
    //网格view
    UIView *gridView;
    
    //裁剪框view
    UIView *frameView;
    
    UILabel *sizeLabel;
    
    BOOL isFirstLayout;
}
@end
@implementation APCutFrameView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)awakeFromNib {
    [super awakeFromNib];
    [self setupData];
    [self setupUI];
}

- (APCutFrameView *)init {
    if (self = [super init]) {
        [self setupData];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews {
    if (!frameView) {
        [self setupUI];
    }
}
#pragma mark - public

- (void)setActiveLen:(CGFloat)activeLen {
    _activeLen = activeLen;
    [self updateFrameView];
}
- (void)setIsShowGrid:(BOOL)isShowGrid {
    _isShowGrid = isShowGrid;
    gridView.hidden = !isShowGrid;
}

- (void)setImgSize:(CGSize)imgSize {
    sizeLabel.text = [NSString stringWithFormat:@"%dx%d", (int)imgSize.width, (int)imgSize.height];
}
#pragma mark - private
- (void)setupData {
    _activeType = -1;
    isFirstLayout = YES;
    _isShowGrid = NO;
    _activeLen = 30;
    frameView = nil;
    gridView = nil;
    sizeLabel = nil;
}
- (void)setupUI {
    [self setupFrameView];
    [self setupGridView];
}

- (void)setupFrameView {
    CGFloat len = self.activeLen/2;
    frameView = [UIView new];
    [self addSubview:frameView];
    frameView.backgroundColor = [UIColor clearColor];
    frameView.alpha = 0.5;
    [frameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
        make.right.equalTo(self.mas_right);
        make.left.equalTo(self.mas_left);
    }];
    //裁剪指示框 12根短线  前6个横线，后6个竖线，都是以左上角起始数起，顺时针。
    for (NSInteger indx = 0; indx < 12; indx++) {
        UIView *view = [UIView new];
        view.tag = indx;
        view.backgroundColor = [UIColor whiteColor];
        [frameView addSubview:view];
        
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            if (indx < 6) {
                make.width.mas_equalTo(20);
                make.height.mas_equalTo(2);
            } else {
                make.width.mas_equalTo(2);
                make.height.mas_equalTo(20);
            }
            NSInteger ix = indx % 6;
            if (ix < 2 || indx == 2) {
                make.top.equalTo(self).mas_equalTo(len-1);
            }
            if ((ix <= 4 && ix > 2) || indx == 5) {
                make.bottom.equalTo(self).mas_equalTo(-len+1);
            }
            if (ix == 2 || ix == 3 || indx == 7) {
                make.right.equalTo(self).mas_equalTo(-len+1);
            }
            if (ix == 0 || ix == 5 || indx == 10) {
                make.left.equalTo(self).mas_equalTo(len-1);
            }
            if (indx == 1 || indx == 4) {
                make.centerX.equalTo(self);
            }
            if (indx == 8 || indx == 11) {
                make.centerY.equalTo(self);
            }
        }];
    }
    
    //4根长框线
    for (NSInteger indx = 0; indx < 4; indx++) {
        UIView *view = [UIView new];
        view.tag = indx + 12;
        view.backgroundColor = [UIColor whiteColor];
        [frameView addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            if (indx % 2 == 0) {
                make.height.mas_equalTo(1);
            } else {
                make.width.mas_equalTo(1);
            }
            if (indx != 2) {
                make.top.equalTo(self.mas_top).mas_offset(len);
            }
            if (indx != 3) {
                make.right.equalTo(self.mas_right).mas_offset(-len);
            }
            if (indx != 0) {
                make.bottom.equalTo(self.mas_bottom).mas_offset(-len);
            }
            if (indx != 1) {
                make.left.equalTo(self.mas_left).mas_offset(len);
            }
        }];
    }
}

- (void)updateFrameView {
    CGFloat len = self.activeLen/2;
    for (UIView *view in frameView.subviews) {
        __block NSInteger tag = view.tag;
        [view mas_updateConstraints:^(MASConstraintMaker *make) {
            if (tag < 12) {
                if (tag < 6) {
                    make.width.mas_equalTo(20);
                    make.height.mas_equalTo(2);
                } else {
                    make.width.mas_equalTo(2);
                    make.height.mas_equalTo(20);
                }
                NSInteger ix = tag % 6;
                if (ix < 2 || tag == 2) {
                    make.top.equalTo(self).mas_equalTo(len-1);
                }
                if ((ix <= 4 && ix > 2) || tag == 5) {
                    make.bottom.equalTo(self).mas_equalTo(-len+1);
                }
                if (ix == 2 || ix == 3 || tag == 7) {
                    make.right.equalTo(self).mas_equalTo(-len+1);
                }
                if (ix == 0 || ix == 5 || tag == 10) {
                    make.left.equalTo(self).mas_equalTo(len-1);
                }
                if (tag == 1 || tag == 4) {
                    make.centerX.equalTo(self);
                }
                if (tag == 8 || tag == 11) {
                    make.centerY.equalTo(self);
                }
            } else {
                tag -= 12;
                if (tag % 2 == 0) {
                    make.width.mas_equalTo(self.bounds.size.width-self.activeLen);
                    make.height.mas_equalTo(1);
                } else {
                    make.width.mas_equalTo(1);
                    make.height.mas_equalTo(self.bounds.size.width-self.activeLen);
                }
                if (tag != 2) {
                    make.top.equalTo(self).mas_offset(len);
                }
                if (tag != 3) {
                    make.right.equalTo(self).mas_offset(-len);
                }
                if (tag != 0) {
                    make.bottom.equalTo(self).mas_offset(-len);
                }
                if (tag != 1) {
                    make.left.equalTo(self).mas_offset(len);
                }
            }
        }];
    }
}

- (void)setupGridView {
    CGFloat len = self.activeLen/2;
    //grid view
    gridView = [UIView new];
    gridView.hidden = !self.isShowGrid;
    gridView.backgroundColor = [UIColor clearColor];
    [self addSubview:gridView];
    [gridView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self).mas_offset(len+1);
        make.right.bottom.equalTo(self).mas_offset(-len-1);
    }];
    
    //横线
    NSMutableArray *listH = [NSMutableArray arrayWithCapacity:5];
    for (NSInteger indx = 0; indx< 5; indx++) {
        UIView *view = [UIView new];
        view.tag = indx;
        view.backgroundColor = [UIColor clearColor];
        [gridView addSubview:view];
        [listH addObject:view];
    }
    UIView *view1 = listH[0];
    UIView *view2 = listH[1];view2.backgroundColor = [UIColor whiteColor];
    UIView *view3 = listH[2];
    UIView *view4 = listH[3];view4.backgroundColor = [UIColor whiteColor];
    UIView *view5 = listH[4];
    [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(gridView.mas_right);
        make.left.equalTo(gridView.mas_left);
        make.top.equalTo(gridView.mas_top);
        make.bottom.equalTo(view2.mas_top);
    }];
    [view2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(gridView.mas_right);
        make.left.equalTo(gridView.mas_left);
        make.top.equalTo(view1.mas_bottom);
        make.bottom.equalTo(view3.mas_top);
        make.height.mas_equalTo(1);
    }];
    [view3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(gridView.mas_right);
        make.left.equalTo(gridView.mas_left);
        make.top.equalTo(view2.mas_bottom);
        make.bottom.equalTo(view4.mas_top);
        make.height.equalTo(view1.mas_height);
    }];
    [view4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(gridView.mas_right);
        make.left.equalTo(gridView.mas_left);
        make.top.equalTo(view3.mas_bottom);
        make.bottom.equalTo(view5.mas_top);
        make.height.mas_equalTo(1);
    }];
    [view5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(gridView.mas_right);
        make.left.equalTo(gridView.mas_left);
        make.top.equalTo(view4.mas_bottom);
        make.bottom.equalTo(gridView.mas_bottom);
        make.height.equalTo(view3.mas_height);
    }];
    
    //竖线
    NSMutableArray *listV = [NSMutableArray arrayWithCapacity:5];
    for (NSInteger indx = 0; indx< 5; indx++) {
        UIView *view = [UIView new];
        view.tag = indx;
        view.backgroundColor = [UIColor clearColor];
        [gridView addSubview:view];
        [listV addObject:view];
    }
    UIView *view11 = listV[0];
    UIView *view22 = listV[1];view22.backgroundColor = [UIColor whiteColor];
    UIView *view33 = listV[2];
    UIView *view44 = listV[3];view44.backgroundColor = [UIColor whiteColor];
    UIView *view55 = listV[4];
    [view11 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(gridView.mas_top);
        make.bottom.equalTo(gridView.mas_bottom);
        make.left.equalTo(gridView.mas_left);
        make.right.equalTo(view22.mas_left);
    }];
    [view22 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(gridView.mas_top);
        make.bottom.equalTo(gridView.mas_bottom);
        make.left.equalTo(view11.mas_right);
        make.right.equalTo(view33.mas_left);
        make.width.mas_equalTo(1);
    }];
    [view33 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(gridView.mas_top);
        make.bottom.equalTo(gridView.mas_bottom);
        make.left.equalTo(view22.mas_right);
        make.right.equalTo(view44.mas_left);
        make.width.equalTo(view11.mas_width);
    }];
    [view44 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(gridView.mas_top);
        make.bottom.equalTo(gridView.mas_bottom);
        make.right.equalTo(view55.mas_left);
        make.left.equalTo(view33.mas_right);
        make.width.mas_equalTo(1);
    }];
    [view55 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(gridView.mas_top);
        make.bottom.equalTo(gridView.mas_bottom);
        make.left.equalTo(view44.mas_right);
        make.right.equalTo(gridView.mas_right);
        make.width.equalTo(view33.mas_width);
    }];
    
    sizeLabel = [UILabel new];
    sizeLabel.text = @"100x100";
    sizeLabel.font = [UIFont systemFontOfSize:12];
    sizeLabel.textColor = [UIColor whiteColor];
    sizeLabel.textAlignment = NSTextAlignmentCenter;
    [gridView addSubview:sizeLabel];
    [sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(gridView.mas_centerX);
        make.centerY.equalTo(gridView.mas_centerY);
        make.height.mas_equalTo(15);
    }];
}
- (void)updateGridView {
    
}
//不在8个地点就传给后面的视图。
- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event {
    return _activeType > 0;
}

//frame内
- (NSInteger)checkActive:(CGPoint)point {
    CGRect frame = self.frame;
    //背景容器坐标转为frame内的坐标
    CGRect topLeft = CGRectMake(0, 0, _activeLen, _activeLen);
    if (CGRectContainsPoint(topLeft, point)) {
        return APGRActiveTypeTopLeft;
    }
    CGRect topRight = CGRectMake(frame.size.width-_activeLen, 0, _activeLen, _activeLen);
    if (CGRectContainsPoint(topRight, point)) {
        return APGRActiveTypeTopRight;
    }
    CGRect rightBottom = CGRectMake(frame.size.width-_activeLen, frame.size.height-_activeLen, _activeLen, _activeLen);
    if (CGRectContainsPoint(rightBottom, point)) {
        return APGRActiveTypeBottomRight;
    }
    CGRect leftBottom = CGRectMake(0, frame.size.height-_activeLen, _activeLen, _activeLen);
    if (CGRectContainsPoint(leftBottom, point)) {
        return APGRActiveTypeBottomLeft;
    }

    CGRect topMid = CGRectMake((frame.size.width-_activeLen)/2, 0, _activeLen, _activeLen);
    if (CGRectContainsPoint(topMid, point)) {
        return APGRActiveTypeTopMid;
    }
    CGRect rightMid = CGRectMake(frame.size.width-_activeLen, (frame.size.height-_activeLen)/2, _activeLen, _activeLen);
    if (CGRectContainsPoint(rightMid, point)) {
        return APGRActiveTypeRightMid;
    }
    CGRect bottomMid = CGRectMake((frame.size.width-_activeLen)/2, frame.size.height-_activeLen, _activeLen, _activeLen);
    if (CGRectContainsPoint(bottomMid, point)) {
        return APGRActiveTypeBottomMid;
    }
    CGRect leftMin = CGRectMake(0, (frame.size.height-_activeLen)/2, _activeLen, _activeLen);
    if (CGRectContainsPoint(leftMin, point)) {
        return APGRActiveTypeLeftMid;
    }

    return -1;
}
@end
