
#import "DDYIndexView.h"

const NSInteger DDYIndexViewInvalidIndex = NSUIntegerMax - 1;
const NSInteger DDYIndexViewSearchIndex  = -1;

static inline UIColor *DDYColor(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha) {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
}

@interface DDYIndexViewConfig ()

@property (nonatomic, assign) DDYIndexViewStyle indexViewStyle;  // 索引元素之间间隔距离

@end

@implementation DDYIndexViewConfig

@synthesize indexViewStyle = _indexViewStyle;


+ (instancetype)configWithIndexViewStyle:(DDYIndexViewStyle)indexViewStyle {
    DDYIndexViewConfig *config = [[DDYIndexViewConfig alloc] init];
    config.indexViewStyle = indexViewStyle;
    config.indicatorBackColor = DDYColor(200, 200, 200, 1);
    config.indicatorTextColor = [UIColor whiteColor];
    config.indicatorTextFont = [UIFont systemFontOfSize:indexViewStyle==DDYIndexViewStyleRight ? 35 : 45];
    config.indicatorHeight = indexViewStyle==DDYIndexViewStyleRight ? 50 : 80;
    config.indicatorRightMargin = 40;
    config.indicatorCornerRadius = 10;
    
    config.indexItemBackgColor = [UIColor clearColor];
    config.indexItemTextColor = [UIColor darkGrayColor];
    config.indexItemSelectedBackColor = DDYColor(40, 170, 40, 1);
    config.indexItemSelectedTextColor = [UIColor whiteColor];
    config.indexItemHeight = 15;
    config.indexItemRightMargin = 5;
    config.indexItemsSpace = 0;
    return config;
}

@end

#define kDDYIndexViewSpace (self.config.indexItemHeight + self.config.indexItemsSpace)
#define kDDYIndexViewMargin ((self.bounds.size.height - kDDYIndexViewSpace * self.dataSource.count) / 2 + 40)

static NSTimeInterval kAnimationDuration = 0.25;
static void * kDDYIndexViewContext = &kDDYIndexViewContext;
static NSString *kDDYFrame = @"frame";
static NSString *kDDYCenter = @"center";
static NSString *kDDYContentOffset = @"contentOffset";

// 根据section值获取CATextLayer的中心点y值
static inline CGFloat ddyLayerCenterY(NSUInteger position, CGFloat margin, CGFloat space) {
    return margin + (position + 1.0 / 2) * space;
}

// 根据y值获取CATextLayer的section值
static inline NSInteger ddyLayerIndex(CGFloat y, CGFloat margin, CGFloat space) {
    CGFloat position = (y - margin) / space - 1.0 / 2;
    if (position <= 0) return 0;
    NSUInteger bigger = (NSUInteger)ceil(position);
    NSUInteger smaller = bigger - 1;
    CGFloat biggerCenterY = ddyLayerCenterY(bigger, margin, space);
    CGFloat smallerCenterY = ddyLayerCenterY(smaller, margin, space);
    return biggerCenterY + smallerCenterY > 2 * y ? smaller : bigger;
}

@interface DDYIndexView ()

@property (nonatomic, strong) CAShapeLayer *searchLayer;
@property (nonatomic, strong) NSMutableArray<CATextLayer *> *subTextLayers;
/** 大字提示 */
@property (nonatomic, strong) UILabel *indicator;
/** 关联的tableView */
@property (nonatomic, strong) UITableView *tableView;
/** 触摸索引视图 */
@property (nonatomic, assign, getter=isTouchingIndexView) BOOL touchingIndexView;
/** 触感反馈 */
@property (nonatomic, strong) UIImpactFeedbackGenerator *generator NS_AVAILABLE_IOS(10_0);

@end

@implementation DDYIndexView

#pragma mark - Life Cycle

- (instancetype)initWithTableView:(UITableView *)tableView config:(DDYIndexViewConfig *)config {
    if (self = [super initWithFrame:tableView.frame]) {
        _tableView = tableView;
        _currentIndex = NSUIntegerMax;
        _config = config;
        _navigationBarTranslucent = YES;
        
        
        [self addSubview:self.indicator];
        
        [tableView addObserver:self forKeyPath:kDDYFrame options:NSKeyValueObservingOptionNew context:kDDYIndexViewContext];
        [tableView addObserver:self forKeyPath:kDDYCenter options:NSKeyValueObservingOptionNew context:kDDYIndexViewContext];
        [tableView addObserver:self forKeyPath:kDDYContentOffset options:NSKeyValueObservingOptionNew context:kDDYIndexViewContext];
    }
    return self;
}

- (void)dealloc {
    [self.tableView removeObserver:self forKeyPath:kDDYFrame];
    [self.tableView removeObserver:self forKeyPath:kDDYCenter];
    [self.tableView removeObserver:self forKeyPath:kDDYContentOffset];
}

- (void)configSubLayersAndSubviews
{
    BOOL hasSearchLayer = [self.dataSource.firstObject isEqualToString:UITableViewIndexSearch];
    NSUInteger deta = 0;
    if (hasSearchLayer) {
        self.searchLayer = [self createSearchLayer];
        [self.layer addSublayer:self.searchLayer];
        deta = 1;
    } else if (self.searchLayer) {
        [self.searchLayer removeFromSuperlayer];
        self.searchLayer = nil;
    }
    
    NSInteger countDifference = self.dataSource.count - deta - self.subTextLayers.count;
    if (countDifference > 0) {
        for (int i = 0; i < countDifference; i++) {
            CATextLayer *textLayer = [CATextLayer layer];
            [self.layer addSublayer:textLayer];
            [self.subTextLayers addObject:textLayer];
        }
    } else {
        for (int i = 0; i < -countDifference; i++) {
            CATextLayer *textLayer = self.subTextLayers.lastObject;
            [textLayer removeFromSuperlayer];
            [self.subTextLayers removeObject:textLayer];
        }
    }
    
    CGFloat space = kDDYIndexViewSpace;
    CGFloat margin = kDDYIndexViewMargin;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    if (hasSearchLayer) {
        self.searchLayer.frame = CGRectMake(self.bounds.size.width - self.config.indexItemRightMargin - self.config.indexItemHeight, ddyLayerCenterY(0, margin, space) - self.config.indexItemHeight / 2, self.config.indexItemHeight, self.config.indexItemHeight);
        self.searchLayer.cornerRadius = self.config.indexItemHeight / 2;
        self.searchLayer.contentsScale = UIScreen.mainScreen.scale;
        self.searchLayer.backgroundColor = self.config.indexItemBackgColor.CGColor;
    }
    
    for (int i = 0; i < self.subTextLayers.count; i++) {
        CATextLayer *textLayer = self.subTextLayers[i];
        NSUInteger section = i + deta;
        textLayer.frame = CGRectMake(self.bounds.size.width - self.config.indexItemRightMargin - self.config.indexItemHeight, ddyLayerCenterY(section, margin, space) - self.config.indexItemHeight / 2, self.config.indexItemHeight, self.config.indexItemHeight);
        textLayer.string = self.dataSource[section];
        textLayer.fontSize = self.config.indexItemHeight * 0.8;
        textLayer.cornerRadius = self.config.indexItemHeight / 2;
        textLayer.alignmentMode = kCAAlignmentCenter;
        textLayer.contentsScale = UIScreen.mainScreen.scale;
        textLayer.backgroundColor = self.config.indexItemBackgColor.CGColor;
        textLayer.foregroundColor = self.config.indexItemTextColor.CGColor;
    }
    [CATransaction commit];
    
    if (self.subTextLayers.count == 0) {
        self.currentIndex = NSUIntegerMax;
    } else if (self.currentIndex == NSUIntegerMax) {
        self.currentIndex = self.searchLayer ? DDYIndexViewSearchIndex : 0;
    } else {
        self.currentIndex = self.subTextLayers.count - 1;
    }
}

- (void)configCurrentIndex
{
    if (!self.tableView || !self.tableView.indexPathsForVisibleRows.count) {
        return;
    }
    NSInteger currentIndex = DDYIndexViewInvalidIndex;
    
    NSInteger firstVisibleSection = self.tableView.indexPathsForVisibleRows.firstObject.section;
    CGFloat insetHeight = 0;
    if (!self.navigationBarTranslucent) {
        currentIndex = firstVisibleSection;
    } else {
        insetHeight = UIApplication.sharedApplication.statusBarFrame.size.height + 44;
        for (NSInteger section = firstVisibleSection; section < self.subTextLayers.count; section++) {
            CGRect sectionFrame = [self.tableView rectForSection:section];
            if (sectionFrame.origin.y + sectionFrame.size.height - self.tableView.contentOffset.y >= insetHeight) {
                currentIndex = section;
                break;
            }
        }
    }
    
    if (currentIndex == 0 && self.searchLayer) {
        CGRect sectionFrame = [self.tableView rectForSection:currentIndex];
        BOOL selectSearchLayer = (sectionFrame.origin.y - self.tableView.contentOffset.y - insetHeight) > 0;
        if (selectSearchLayer) {
            currentIndex = DDYIndexViewSearchIndex;
        }
    }
    
    if (currentIndex < 0 && currentIndex != DDYIndexViewSearchIndex) return;
    self.currentIndex = currentIndex;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (context != kDDYIndexViewContext) return;
    
    if ([keyPath isEqualToString:kDDYCenter] || [keyPath isEqualToString:kDDYFrame]) {
        self.frame = self.tableView.frame;
        
        CGFloat space = kDDYIndexViewSpace;
        CGFloat margin = kDDYIndexViewMargin;
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        if (self.searchLayer) {
            self.searchLayer.frame = CGRectMake(self.bounds.size.width - self.config.indexItemRightMargin - self.config.indexItemHeight, ddyLayerCenterY(0, margin, space) - self.config.indexItemHeight / 2, self.config.indexItemHeight, self.config.indexItemHeight);
            self.searchLayer.cornerRadius = self.config.indexItemHeight / 2;
            self.searchLayer.contentsScale = UIScreen.mainScreen.scale;
            self.searchLayer.backgroundColor = self.config.indexItemBackgColor.CGColor;
        }
        
        NSInteger deta = self.searchLayer ? 1 : 0;
        for (int i = 0; i < self.subTextLayers.count; i++) {
            CATextLayer *textLayer = self.subTextLayers[i];
            NSUInteger section = i + deta;
            textLayer.frame = CGRectMake(self.bounds.size.width - self.config.indexItemRightMargin - self.config.indexItemHeight, ddyLayerCenterY(section, margin, space) - self.config.indexItemHeight / 2, self.config.indexItemHeight, self.config.indexItemHeight);
        }
        [CATransaction commit];
    } else if ([keyPath isEqualToString:kDDYContentOffset]) {
        [self onActionWithScroll];
    }
}

#pragma mark - Event Response

- (void)onActionWithDidSelect
{
    if ((self.currentIndex < 0 && self.currentIndex != DDYIndexViewSearchIndex)
        || self.currentIndex >= (NSInteger)self.subTextLayers.count) {
        return;
    }
    
    if (self.currentIndex == DDYIndexViewSearchIndex) {
        CGFloat insetHeight = self.navigationBarTranslucent ? UIApplication.sharedApplication.statusBarFrame.size.height + 44 : 0;
        [self.tableView setContentOffset:CGPointMake(0, -insetHeight) animated:NO];
    } else {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:self.currentIndex];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    
    if (self.isTouchingIndexView) {
        if (@available(iOS 10.0, *)) {
            [self.generator prepare];
            [self.generator impactOccurred];
        }
    }
}

- (void)onActionWithScroll
{
    if (self.isTouchingIndexView) {
        // 当滑动tableView视图时，另一手指滑动索引视图，让tableView滑动失效
        self.tableView.panGestureRecognizer.enabled = NO;
        self.tableView.panGestureRecognizer.enabled = YES;
        
        return; // 当滑动索引视图时，tableView滚动不能影响索引位置
    }
    
    // 可能tableView的contentOffset变化，却没有scroll，此时不应该影响索引位置
    BOOL isScrolling = self.tableView.isDragging || self.tableView.isDecelerating;
    if (!isScrolling) return;
    
    [self configCurrentIndex];
}

#pragma mark - Display


- (CAShapeLayer *)createSearchLayer {
    CGFloat radius = self.config.indexItemHeight / 4;
    CGFloat margin = self.config.indexItemHeight / 4;
    CGFloat start = radius * 2.5 + margin;
    CGFloat end = radius + sin(M_PI_4) * radius + margin;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(start, start)];
    [path addLineToPoint:CGPointMake(end, end)];
    [path addArcWithCenter:CGPointMake(radius + margin, radius + margin) radius:radius startAngle:M_PI_4 endAngle:2 * M_PI + M_PI_4 clockwise:YES];
    [path closePath];
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.fillColor = self.config.indexItemBackgColor.CGColor;
    layer.strokeColor = self.config.indexItemTextColor.CGColor;
    layer.contentsScale = [UIScreen mainScreen].scale;
    layer.lineWidth = self.config.indexItemHeight / 12;
    layer.path = path.CGPath;
    return layer;
}

- (void)showIndicator:(BOOL)animated
{
    if (!self.indicator.hidden || self.currentIndex < 0 || self.currentIndex >= (NSInteger)self.subTextLayers.count) return;
    
    CATextLayer *textLayer = self.subTextLayers[self.currentIndex];
    if (self.config.indexViewStyle == DDYIndexViewStyleRight) {
        self.indicator.center = CGPointMake(self.bounds.size.width - self.indicator.bounds.size.width / 2 - self.config.indicatorRightMargin, textLayer.position.y);
    } else {
        self.indicator.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    }
    self.indicator.text = textLayer.string;
    
    if (animated) {
        self.indicator.alpha = 0;
        self.indicator.hidden = NO;
        [UIView animateWithDuration:kAnimationDuration animations:^{
            self.indicator.alpha = 1;
        }];
    } else {
        self.indicator.alpha = 1;
        self.indicator.hidden = NO;
    }
}

- (void)hideIndicator:(BOOL)animated
{
    if (self.indicator.hidden) return;
    
    if (animated) {
        self.indicator.alpha = 1;
        self.indicator.hidden = NO;
        [UIView animateWithDuration:kAnimationDuration animations:^{
            self.indicator.alpha = 0;
        } completion:^(BOOL finished) {
            self.indicator.alpha = 1;
            self.indicator.hidden = YES;
        }];
    } else {
        self.indicator.alpha = 1;
        self.indicator.hidden = YES;
    }
}

- (void)refreshTextLayer:(BOOL)selected
{
    if (self.currentIndex < 0 || self.currentIndex >= (NSInteger)self.subTextLayers.count) return;
    
    CATextLayer *textLayer = self.subTextLayers[self.currentIndex];
    UIColor *backgroundColor, *foregroundColor;
    if (selected) {
        backgroundColor = self.config.indexItemSelectedBackColor;
        foregroundColor = self.config.indexItemSelectedTextColor;
    } else {
        backgroundColor = self.config.indexItemBackgColor;
        foregroundColor = self.config.indexItemTextColor;
    }
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    textLayer.backgroundColor = backgroundColor.CGColor;
    textLayer.foregroundColor = foregroundColor.CGColor;
    [CATransaction commit];
}

#pragma mark - UITouch and UIEvent

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    // 当滑动索引视图时，防止其他手指去触发事件
    if (self.touchingIndexView) return YES;
    
    CALayer *firstLayer = self.searchLayer ?: self.subTextLayers.firstObject;
    if (!firstLayer) return NO;
    CALayer *lastLayer = self.subTextLayers.lastObject ?: self.searchLayer;
    if (!lastLayer) return NO;
    
    CGFloat space = self.config.indexItemRightMargin * 2;
    if (point.x > self.bounds.size.width - space - self.config.indexItemHeight
        && point.y > CGRectGetMinY(firstLayer.frame) - space
        && point.y < CGRectGetMaxY(lastLayer.frame) + space) {
        return YES;
    }
    return NO;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.touchingIndexView = YES;
    CGPoint location = [touch locationInView:self];
    NSInteger currentPosition = ddyLayerIndex(location.y, kDDYIndexViewMargin, kDDYIndexViewSpace);
    if (currentPosition < 0 || currentPosition >= (NSInteger)self.dataSource.count) return YES;
    
    NSInteger deta = self.searchLayer ? 1 : 0;
    NSInteger currentIndex = currentPosition - deta;
    [self hideIndicator:NO];
    self.currentIndex = currentIndex;
    [self showIndicator:YES];
    [self onActionWithDidSelect];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.touchingIndexView = YES;
    CGPoint location = [touch locationInView:self];
    NSInteger currentPosition = ddyLayerIndex(location.y, kDDYIndexViewMargin, kDDYIndexViewSpace);
    
    if (currentPosition < 0) {
        currentPosition = 0;
    } else if (currentPosition >= (NSInteger)self.dataSource.count) {
        currentPosition = self.dataSource.count - 1;
    }
    
    NSInteger deta = self.searchLayer ? 1 : 0;
    NSInteger currentIndex = currentPosition - deta;
    if (currentIndex == self.currentIndex) return YES;
    
    [self hideIndicator:NO];
    self.currentIndex = currentIndex;
    [self showIndicator:NO];
    [self onActionWithDidSelect];
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.touchingIndexView = NO;
    [self hideIndicator:YES];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    self.touchingIndexView = NO;
    [self hideIndicator:YES];
}

#pragma mark - Getters and Setters

- (void)setDataSource:(NSArray<NSString *> *)dataSource
{
    if (_dataSource == dataSource) return;
    
    _dataSource = dataSource.copy;
    
    [self configSubLayersAndSubviews];
    [self configCurrentIndex];
}

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    if ((currentIndex < 0 && currentIndex != DDYIndexViewSearchIndex)
        || currentIndex >= (NSInteger)self.subTextLayers.count
        || currentIndex == _currentIndex) return;
    
    [self refreshTextLayer:NO];
    _currentIndex = currentIndex;
    [self refreshTextLayer:YES];
}

- (NSMutableArray *)subTextLayers
{
    if (!_subTextLayers) {
        _subTextLayers = [NSMutableArray array];
    }
    return _subTextLayers;
}

- (UILabel *)indicator
{
    if (!_indicator) {
        _indicator = [UILabel new];
        _indicator.layer.backgroundColor = self.config.indicatorBackColor.CGColor;
        _indicator.textColor = self.config.indicatorTextColor;
        _indicator.font = self.config.indicatorTextFont;
        _indicator.textAlignment = NSTextAlignmentCenter;
        _indicator.hidden = YES;
        
        switch (self.config.indexViewStyle) {
            case DDYIndexViewStyleRight:
            {
                CGFloat indicatorH = self.config.indicatorHeight;
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
                _indicator.bounds = CGRectMake(0, 0, indicatorW, indicatorH);
                _indicator.layer.mask = maskLayer;
            }
                break;
                
            case DDYIndexViewStyleCenter:
            {
                _indicator.bounds = CGRectMake(0, 0, self.config.indicatorHeight, self.config.indicatorHeight);
                _indicator.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
                _indicator.layer.cornerRadius = self.config.indicatorCornerRadius;
            }
                break;
                
            default:
                break;
        }
    }
    return _indicator;
}

- (UIImpactFeedbackGenerator *)generator {
    if (!_generator) {
        _generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
    }
    return _generator;
}

@end
