#import "DDYSectionIndex.h"


static inline UIColor *color(CGFloat r, CGFloat g, CGFloat b, CGFloat a) { // arc4random_uniform(256)
    return [UIColor colorWithRed:(r)/255. green:(g)/255. blue:(b)/255. alpha:a];
}

@interface DDYSectionIndex ()
/** 索引数组 */
@property (nonatomic, strong) NSMutableArray <CALayer *>*titleLayers;
/** 选择指示 */
@property (nonatomic, strong) UILabel *indicator;
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
    
}

//- (CAShapeLayer *)searchLayer {
//
//}

- (void)textLayerWithIndex:(int)index {

    NSMutableArray *tempLayerArray = [NSMutableArray array];
    for (int i = 0; i < _dataSource.count; i++) {
        @autoreleasepool {
            CGFloat x = self.bounds.size.width - self.indexRightMargin - self.indexItemHeight;
            CGFloat y = (self.bounds.size.height - self.indexItemHeight*_dataSource.count)/2. + self.indexItemHeight * index;
            CGFloat w = self.indexItemHeight;
            CGFloat h = self.indexItemHeight;
            NSString *title = _dataSource[index];
            
            if ([title isEqualToString:UITableViewIndexSearch]) {
                
            } else {
                CATextLayer *textLayer = [CATextLayer layer];
                [textLayer setFrame:CGRectMake(x, y, w, h)];
                [textLayer setString:self.dataSource[index]];
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

#pragma mark - 事件
static BOOL isTouched;
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (isTouched) return YES;
    
    return NO;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    isTouched = YES;
    
}

@end

/**
 
 [arr addObject:@"{search}"];//等价于[arr addObject:UITableViewIndexSearch];
 */
