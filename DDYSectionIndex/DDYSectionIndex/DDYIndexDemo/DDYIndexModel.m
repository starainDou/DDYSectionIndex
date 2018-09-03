#import "DDYIndexModel.h"

@implementation DDYIndexModel

+ (NSArray<DDYIndexModel *> *)testModelArray {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"DDYSectionIndexData" ofType:@"plist"];
    NSArray *tempArray = [NSArray arrayWithContentsOfFile:plistPath];
    NSMutableArray *modelArray = [NSMutableArray array];
    for (NSString *tempString in tempArray) {
        DDYIndexModel *tempMoel = [[DDYIndexModel alloc] init];
        tempMoel.title = tempString;
        [modelArray addObject:tempMoel];
    }
    return modelArray;
}

@end
