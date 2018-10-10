
#import <UIKit/UIKit.h>

extern const NSInteger DDYIndexViewInvalidIndex;
extern const NSInteger DDYIndexViewSearchIndex;

typedef NS_ENUM(NSUInteger, DDYIndexViewStyle) {
    DDYIndexViewStyleRight = 0, // 指向点
    DDYIndexViewStyleCenter,    // 中心提示弹层
};

@interface DDYIndexViewConfig : NSObject

@property (nonatomic, assign, readonly) DDYIndexViewStyle indexViewStyle;    // 索引提示风格

@property (nonatomic, strong) UIColor *indicatorBackColor;                  // 指示器背景颜色
@property (nonatomic, strong) UIColor *indicatorTextColor;                  // 指示器文字颜色
@property (nonatomic, strong) UIFont *indicatorTextFont;                    // 指示器文字字体
@property (nonatomic, assign) CGFloat indicatorHeight;                      // 指示器高度
@property (nonatomic, assign) CGFloat indicatorRightMargin;                 // 指示器距离右边屏幕距离（default有效）
@property (nonatomic, assign) CGFloat indicatorCornerRadius;                // 指示器圆角半径（centerToast有效）

@property (nonatomic, strong) UIColor *indexItemBackgColor;                 // 索引元素背景颜色
@property (nonatomic, strong) UIColor *indexItemTextColor;                  // 索引元素文字颜色
@property (nonatomic, strong) UIColor *indexItemSelectedBackColor;          // 索引元素选中时背景颜色
@property (nonatomic, strong) UIColor *indexItemSelectedTextColor;          // 索引元素选中时文字颜色
@property (nonatomic, assign) CGFloat indexItemHeight;                      // 索引元素高度
@property (nonatomic, assign) CGFloat indexItemRightMargin;                 // 索引元素距离右边屏幕距离
@property (nonatomic, assign) CGFloat indexItemsSpace;                      // 索引元素之间间隔距离

+ (instancetype)configWithIndexViewStyle:(DDYIndexViewStyle)indexViewStyle;

@end


@interface DDYIndexView : UIControl

/** 索引视图数据源 */
@property (nonatomic, copy) NSArray<NSString *> *dataSource;
/** 当前索引位置 */
@property (nonatomic, assign) NSInteger currentIndex;
/** tableView在NavigationBar上是否半透明 */
@property (nonatomic, assign) BOOL navigationBarTranslucent;
/** 索引视图的配置 */
@property (nonatomic, strong, readonly) DDYIndexViewConfig *config;
/** DDYIndexView 会对 tableView 进行 strong 引用，请注意，防止“循环引用” */
- (instancetype)initWithTableView:(UITableView *)tableView config:(DDYIndexViewConfig *)config;

@end
