#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DDYSectionIndexStyle) {
    DDYSectionIndexStyleRight = 0,  // 右边
    DDYSectionIndexStyleCenter,     // 中间
};

@interface DDYSectionIndex : UIControl
/** 数据源 必选 */
@property (nonatomic, strong) NSArray <NSString *>*dataSource;

/** 样式 可选(默认DDYSectionIndexStyleRight) */
@property (nonatomic, assign) DDYSectionIndexStyle indexStyle;

/** 索引文字颜色 可选(默认[UIColor darkGrayColor]) */
@property (nonatomic, strong) UIColor *indexTextColor;
/** 索引选中时文字颜色 可选(默认[UIColor whiteColor]) */
@property (nonatomic, strong) UIColor *indexTextSelectedColor;
/** 索引背景颜色 可选(默认[UIColor clearColor]) */
@property (nonatomic, strong) UIColor *indexBackColor;
/** 索引选中时背景颜色 可选(默认 r:40 g:170 b:40 a:1) */
@property (nonatomic, strong) UIColor *indexBackSelectedColor;
/** 索引元素高度 可选(默认15) */
@property (nonatomic, assign) CGFloat indexItemHeight;
/** 索引与屏幕右边距 可选(默认5) */
@property (nonatomic, assign) CGFloat indexRightMargin;

/** 指示器文字颜色 可选(默认[UIColor whiteColor]) */
@property (nonatomic, strong) UIColor *indicatorTextColor;
/** 指示器文字字体 可选(默认[UIFont systemFontOfSize:38]) */
@property (nonatomic, strong) UIFont *indicatorTextFont;
/** 指示器背景颜色 可选(默认200, 200, 200, 0.8) */
@property (nonatomic, strong) UIColor *indicatorBackColor;

/** 点中(滑中)回调 */
@property (nonatomic, copy) void (^selectedIndexBlock)(NSInteger index);

@end
