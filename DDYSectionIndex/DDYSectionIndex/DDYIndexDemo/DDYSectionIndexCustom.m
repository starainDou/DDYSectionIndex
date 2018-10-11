// !!!:
// MARK: 此为demo
// !!!:

#import "DDYSectionIndexCustom.h"
#import "UITableView+DDYIndexView.h"
#import "DDYIndexModel.h"
#import "NSArray+DDYExtension.h"

#ifndef DDYScreenW
#define DDYScreenW [UIScreen mainScreen].bounds.size.width
#endif

@interface DDYSectionIndexCustom ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
/** 排序后的模型数组 */
@property (nonatomic, strong) NSMutableArray <NSArray *>*modelsArray;
/** 分组标题数组 */
@property (nonatomic, strong) NSMutableArray <NSString *>*titlesArray;

@end

@implementation DDYSectionIndexCustom

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
        _tableView.sectionIndexColor = [UIColor blueColor];
        _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        _tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
        _tableView.sectionIndexMinimumDisplayRowCount = 6;
        
        _tableView.ddy_IndexViewConfig = [DDYIndexViewConfig configWithIndexViewStyle:self.indexViewStyle];
        _tableView.ddy_NavigationBarTranslucent = YES;
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    self.tableView.tableHeaderView = self.hasSearch ? [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, DDYScreenW, 50)] : [UIView new];
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
        // 原始数据(1000多条)
        NSArray *originalArray = [DDYIndexModel testModelArray];
        // 模型排序
        [originalArray ddy_ModelSortSelector:@selector(title) complete:^(NSArray *modelsArray, NSArray *titlesArray) {
            self.modelsArray = [NSMutableArray arrayWithArray:modelsArray];
            self.titlesArray = [NSMutableArray arrayWithArray:titlesArray];
            
            NSMutableArray *tempArray =[NSMutableArray arrayWithArray:titlesArray];
            if (self.hasSearch) [tempArray insertObject:UITableViewIndexSearch atIndex:0];
            self.tableView.ddy_IndexViewDataSource = tempArray.copy;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
    });
}

@end
