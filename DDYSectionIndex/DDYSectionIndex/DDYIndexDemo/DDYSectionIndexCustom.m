// !!!:
// MARK: 此为demo
// !!!:

#import "DDYSectionIndexCustom.h"

@interface DDYSectionIndexCustom ()

@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation DDYSectionIndexCustom

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1
    NSMutableArray *tempArray = [NSMutableArray array];
    [tempArray addObject:@"你的模型"];
    self.dataSource = [NSMutableArray arrayWithArray:tempArray];
    
    // 2
    [self.dataSource removeAllObjects];
    [self.dataSource addObject:@"你的模型"];
    
    // 3
    self.dataSource = nil;
    self.dataSource = [NSMutableArray array];//懒加载就不用这样了
    [self.dataSource addObject:@"你的模型"];
    
    
}

@end
