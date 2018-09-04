#import "DDYSectionIndex.h"

static BOOL isTouched;

static inline UIColor *color(CGFloat r, CGFloat g, CGFloat b, CGFloat a) { // arc4random_uniform(256)
    return [UIColor colorWithRed:(r)/255. green:(g)/255. blue:(b)/255. alpha:a];
}

@interface DDYSectionIndex ()
/** 索引数组 */
@property (nonatomic, strong) NSMutableArray <CALayer *>*titleLayers;
/** 选择指示 */
@property (nonatomic, strong) UILabel *indicator;
/** 当前序列 */
@property (nonatomic, assign) NSInteger currentIndex;
/** 触感反馈 */
@property (nonatomic, strong) UIImpactFeedbackGenerator *feedbackGenerator NS_AVAILABLE_IOS(10_0);

@end

@implementation DDYSectionIndex

#pragma mark 索引浮窗指示器
- (UILabel *)indicator {
    if (!_indicator) {
        _indicator = [[UILabel alloc] init];
        [_indicator setBackgroundColor:color(200, 200, 200, 0.8)];
        [_indicator setTextColor:color(255, 255, 255, 1)];
        [_indicator setFont:[UIFont systemFontOfSize:38]];
        [_indicator setTextAlignment:NSTextAlignmentCenter];
        [_indicator setHidden:YES];
        
    }
    return _indicator;
}

- (UIImpactFeedbackGenerator *)feedbackGenerator {
    if (!_feedbackGenerator) {
        _feedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
    }
    return _feedbackGenerator;
}

- (NSMutableArray<CALayer *> *)titleLayers {
    if (!_titleLayers) {
        _titleLayers = [NSMutableArray array];
    }
    return _titleLayers;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.indexStyle = DDYSectionIndexStyleRight;
        self.indexTextColor = [UIColor darkGrayColor];
        self.indexTextSelectedColor = [UIColor whiteColor];
        self.indexBackColor = [UIColor clearColor];
        self.indexBackSelectedColor = color(40, 170, 40, 1);
        self.indexItemHeight = 15;
        self.indexRightMargin = 5;
        self.indicatorTextColor = [UIColor whiteColor];
        self.indicatorTextFont = [UIFont systemFontOfSize:38];
        self.indicatorBackColor = color(200, 200, 200, 0.8);
    }
    return self;
}

- (void)setIndexStyle:(DDYSectionIndexStyle)indexStyle {
    _indexStyle = indexStyle;
    if (_indexStyle == DDYSectionIndexStyleCenter) {
        [self.indicator setFrame:CGRectMake(0, 0, 120, 120)];
        [self.indicator setCenter:CGPointMake(self.bounds.size.width/2., self.bounds.size.height/2.)];
        [self.indicator.layer setCornerRadius:10];
    } else {
        CGFloat indicatorH = 50.;
        CGFloat indicatorW = sin(M_PI_4) * indicatorH * 2;
        CGPoint startPoint = CGPointMake(indicatorW*3/4. , indicatorH/2.-indicatorW/4.);
        CGPoint trianglePoint = CGPointMake(indicatorW, indicatorH/2.);
        CGPoint centerPoint = CGPointMake(indicatorW/2., indicatorH/2.);
    
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        [bezierPath moveToPoint:startPoint];
        [bezierPath addArcWithCenter:centerPoint radius:indicatorH/2. startAngle:-M_PI_4 endAngle:M_PI_4 clockwise:NO];
        [bezierPath addLineToPoint:trianglePoint];
        [bezierPath addLineToPoint:startPoint];
        [bezierPath closePath];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.path = bezierPath.CGPath;
        [self.indicator setFrame:CGRectMake(0, 0, indicatorW, indicatorH)];
        [self.indicator.layer setMask:maskLayer];
    }
}

- (void)setDataSource:(NSArray<NSString *> *)dataSource {
    if (_dataSource == dataSource) return;
    _dataSource = [dataSource copy];
    [self configLayer];
}

//- (CAShapeLayer *)searchLayer {
//
//}

- (void)configLayer {

    NSMutableArray *tempLayerArray = [NSMutableArray array];
    for (int i = 0; i < _dataSource.count; i++) {
        @autoreleasepool {
            NSString *title = _dataSource[i];
            
            if ([title isEqualToString:UITableViewIndexSearch]) {
                
            } else {
                CATextLayer *textLayer = [CATextLayer layer];
                [textLayer setFrame:[self frameWithIndex:i]];
                [textLayer setString:self.dataSource[i]];
                [textLayer setFontSize: self.indexItemHeight * 0.8];
                [textLayer setCornerRadius: self.indexItemHeight/2.];
                [textLayer setAlignmentMode:kCAAlignmentCenter];
                [textLayer setContentsScale:[UIScreen mainScreen].scale];
                [textLayer setBackgroundColor:self.indexBackColor.CGColor];
                [textLayer setForegroundColor:self.indexTextColor.CGColor];
                [tempLayerArray addObject:textLayer];
            }
        }
    }
    self.titleLayers = [NSMutableArray arrayWithArray:tempLayerArray];
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    if (currentIndex<0 || currentIndex>=self.dataSource.count || currentIndex==_currentIndex) return;
    [self textLayerUpdate:NO];
    _currentIndex = currentIndex;
    [self textLayerUpdate:YES];
}

#pragma mark 根据index获取坐标
- (CGRect)frameWithIndex:(int)index {
    CGFloat x = self.bounds.size.width - self.indexRightMargin - self.indexItemHeight;
    CGFloat y = (self.bounds.size.height - self.indexItemHeight*_dataSource.count)/2. + self.indexItemHeight * index;
    CGFloat w = self.indexItemHeight;
    CGFloat h = self.indexItemHeight;
    return CGRectMake(x, y, w, h);
}

#pragma mark 根据坐标y值获取index
- (NSInteger)indexWithPointY:(CGFloat)pointY adjust:(BOOL)adjust {
    CGFloat y = (self.bounds.size.height - self.indexItemHeight*_dataSource.count)/2.;
    NSInteger tempIndex = (NSInteger)ceil((pointY - y)/self.indexItemHeight);
    if (adjust) {
        return MIN(MAX(0, tempIndex), self.dataSource.count - 1);
    }
    return tempIndex;
}

#pragma mark 处理指示器
- (void)indicatorShow:(BOOL)show animated:(BOOL)animated {
    if ((show && !self.indicator.hidden) || (!show && self.indicator.hidden)) return;
    if (show) {
        self.indicator.hidden = YES;
        CALayer *tempLayer = self.titleLayers[self.currentIndex];
        if ([tempLayer isKindOfClass:[CATextLayer class]]) {
            self.indicator.text = [(CATextLayer *)tempLayer string];
            self.indicator.hidden = NO;
            [UIView animateWithDuration:animated ? 0.25 : 0 animations:^{
                self.indicator.alpha = 1;
            }];
        }
    } else {
        [UIView animateWithDuration:animated ? 0.25 : 0 animations:^{
            self.indicator.alpha = 0;
        } completion:^(BOOL finished) {
            self.indicator.hidden = YES;
        }];
    }
}

#pragma mark 索引元素更新
- (void)textLayerUpdate:(BOOL)selected {
    CALayer *tempLayer = self.titleLayers[self.currentIndex];
    if ([tempLayer isKindOfClass:[CATextLayer class]]) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [(CATextLayer *)tempLayer setBackgroundColor:selected ? self.indexBackSelectedColor.CGColor : self.indexBackColor.CGColor];
        [(CATextLayer *)tempLayer setForegroundColor:selected ? self.indexTextSelectedColor.CGColor : self.indexTextColor.CGColor];
        [CATransaction commit];
    }
}

#pragma mark 触感反馈
- (void)openFeedbackGenerator {
    if (@available(iOS 10.0, *)) {
        if (isTouched) {
            [self.feedbackGenerator prepare];
            [self.feedbackGenerator impactOccurred];
        }
    }
}

#pragma mark - 事件
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (isTouched) return YES;
    if (!self.titleLayers || self.titleLayers.count==0) return NO;
    CALayer *firstLayer = self.titleLayers.firstObject;
    CALayer *lastLayer = self.titleLayers.lastObject;
    if (point.x > firstLayer.frame.origin.x-self.indexRightMargin &&
        point.y > firstLayer.frame.origin.y-self.indexRightMargin &&
        point.y < CGRectGetMaxY(lastLayer.frame) + self.indexRightMargin) {
         return YES;
    }
    return NO;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    isTouched = YES;
    CGPoint point = [touch locationInView:self];
    NSInteger currentIndex = [self indexWithPointY:point.y adjust:NO];
    if (currentIndex < 0 || currentIndex>=self.dataSource.count) return YES;
    self.currentIndex = currentIndex;
    [self indicatorShow:YES animated:YES];
    if (self.selectedIndexBlock) self.selectedIndexBlock(currentIndex);
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    isTouched = YES;
    CGPoint point = [touch locationInView:self];
    NSInteger currentIndex = [self indexWithPointY:point.y adjust:YES];
    if (currentIndex == self.currentIndex) return YES;
    self.currentIndex = currentIndex;
    [self indicatorShow:YES animated:YES];
    if (self.selectedIndexBlock) self.selectedIndexBlock(currentIndex);
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    isTouched = NO;
    [self indicatorShow:NO animated:YES];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
    isTouched = NO;
    [self indicatorShow:NO animated:YES];
}

@end

/**
 [arr addObject:@"{search}"];//等价于[arr addObject:UITableViewIndexSearch];
 */
