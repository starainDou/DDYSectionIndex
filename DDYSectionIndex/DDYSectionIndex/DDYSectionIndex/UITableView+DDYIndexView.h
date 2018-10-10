
#import <UIKit/UIKit.h>
#import "DDYIndexView.h"

@interface UITableView (DDYIndexView)
/** 配置 */
@property (nonatomic, strong) DDYIndexViewConfig *ddy_IndexViewConfig;
/** 索引视图数据源 */
@property (nonatomic, copy) NSArray<NSString *> *ddy_IndexViewDataSource;
/** 用自定义时不再显示系统的索引 */
@property (nonatomic, assign) BOOL ddy_ReplaceSystemSectionIndex;
/** NavigationBar是否半透明 */
@property (nonatomic, assign) BOOL ddy_NavigationBarTranslucent;

@end
