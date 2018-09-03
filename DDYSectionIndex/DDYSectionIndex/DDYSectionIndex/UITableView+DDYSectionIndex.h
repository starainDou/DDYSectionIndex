#import <UIKit/UIKit.h>
#import "DDYSectionIndex.h"

@interface UITableView (DDYSectionIndex)

/** 设置样式 默认DDYSectionIndexStyleRight */
@property (nonatomic, assign) DDYSectionIndexStyle ddySectionIndexStyle;
/** 是否取代系统索引 默认不替换(自定义索引不显示) */
@property (nonatomic, assign) BOOL replaceSystemSectionIndex;

/** 索引文字颜色 */
@property (nonatomic, strong) UIColor *ddySectionIndexTextColor;
/** 索引选中时文字颜色 */
@property (nonatomic, strong) UIColor *ddySectionIndexTextSelectedColor;
/** 索引背景颜色 */
@property (nonatomic, strong) UIColor *ddySectionIndexBackColor;
/** 索引选中时背景颜色 */
@property (nonatomic, strong) UIColor *ddySectionIndexBackSelectedColor;
/** 索引元素高度 */
@property (nonatomic, assign) CGFloat ddySectionIndexItemHeight;
/** 索引与屏幕右边距 */
@property (nonatomic, assign) CGFloat ddySectionIndexRightMargin;
/** 索引元素与元素间距 */
@property (nonatomic, assign) CGFloat ddySectionIndexItemsMargin;

/** 指示器文字颜色 */
@property (nonatomic, strong) UIColor *ddySectionIndicatorTextColor;
/** 指示器文字字体 */
@property (nonatomic, strong) UIFont *ddySectionIndicatorTextFont;
/** 指示器背景颜色 */
@property (nonatomic, strong) UIColor *ddySectionIndicatorBackColor;

@end
