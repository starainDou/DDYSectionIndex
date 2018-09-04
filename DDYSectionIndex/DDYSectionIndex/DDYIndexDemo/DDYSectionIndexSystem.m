#import "DDYSectionIndexSystem.h"
#import "DDYIndexModel.h"
#import "NSArray+DDYExtension.h"

@interface DDYSectionIndexSystem ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
/** 排序后的模型数组 */
@property (nonatomic, strong) NSMutableArray <NSArray *>*modelsArray;
/** 分组标题数组 */
@property (nonatomic, strong) NSMutableArray <NSString *>*titlesArray;

@end

@implementation DDYSectionIndexSystem

- (NSMutableArray<NSArray *> *)modelsArray {
    if (!_modelsArray) {
        _modelsArray = [NSMutableArray array];
    }
    return _modelsArray;
}

- (NSMutableArray<NSString *> *)titlesArray {
    if (!_titlesArray) {
        _titlesArray = [NSMutableArray array];
    }
    return _titlesArray;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        
        // 索引文字颜色
        _tableView.sectionIndexColor = [UIColor blueColor];
        // 索引普通状态背景色
        _tableView.sectionIndexBackgroundColor = [UIColor redColor];
        // 索引按住状态背景色
        _tableView.sectionIndexTrackingBackgroundColor = [UIColor yellowColor];
        // 当小于某个值则隐藏索引
        _tableView.sectionIndexMinimumDisplayRowCount = 6;
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    [self loadTestData];
}

#pragma mark - 分组
#pragma mark 分组数目
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.titlesArray.count;
}
#pragma mark 分组标题
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.titlesArray[section];
}

#pragma mark - 索引
#pragma mark section右侧index数组
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.titlesArray;
}

#pragma mark 点击右侧索引表项时调用 索引与section的对应关系
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

#pragma mark - 行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.modelsArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DDYSectionIndexSystem"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DDYSectionIndexSystem"];
    }
    DDYIndexModel *model = self.modelsArray[indexPath.section][indexPath.row];
    cell.textLabel.text = model.title;
    return cell;
}

- (void)loadTestData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 原始数据
        NSArray *originalArray = [DDYIndexModel testModelArray];
        // 模型排序
        [originalArray ddy_ModelSortSelector:@selector(title) complete:^(NSArray *modelsArray, NSArray *titlesArray) {
            self.modelsArray = [NSMutableArray arrayWithArray:modelsArray];
            self.titlesArray = [NSMutableArray arrayWithArray:titlesArray];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
    });
}

@end

/** 这里不考虑转拼音以及排序最最最优化，事实证明网上说的转拼音的优化，我打印的反而更耗时 */
