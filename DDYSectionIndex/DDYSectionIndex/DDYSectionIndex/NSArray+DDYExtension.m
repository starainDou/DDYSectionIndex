#import "NSArray+DDYExtension.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <UIKit/UIKit.h>

@implementation NSArray (DDYExtension)

#pragma mark  对模型数组进行索引排序
- (void)ddy_ModelSortSelector:(SEL)selector complete:(void (^)(NSArray *modelsArray, NSArray *titlesArray))complete {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 索引规则对象
        UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
        // 索引数量（26个字母和1个#）
        NSInteger sectionTitlesCount = collation.sectionTitles.count;
        // 临时存储分组的数组
        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
        // 最终去空的分组数组
        NSMutableArray *sortedModelArray = [NSMutableArray arrayWithCapacity:sectionTitlesCount];
        // 最终储存标题的数组
        NSMutableArray *sectionTitleArray = [NSMutableArray arrayWithCapacity:sectionTitlesCount];
        // @[ @[A], @[B], @[C] ... @[Z], @[#] ] 27个空数组(@[ @[], @[], @[] ... @[], @[] ])
        for (int i = 0; i < sectionTitlesCount; i++) {
            [tempArray addObject:[NSMutableArray array]];
        }
        // 按selector参数分配到数组
        for (id obj in self) {
            NSInteger sectionNumber = [collation sectionForObject:obj collationStringSelector:selector];
            [[tempArray objectAtIndex:sectionNumber] addObject:obj];
        }
        // 对每个数组按排序 同时去除空数组
        for (int i = 0; i < sectionTitlesCount; i++) {
            if (tempArray[i] && [tempArray[i] count]) {
                [sortedModelArray addObject:[collation sortedArrayFromArray:tempArray[i] collationStringSelector:selector]];
                [sectionTitleArray addObject:[UILocalizedIndexedCollation currentCollation].sectionTitles[i]];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(sortedModelArray, sectionTitleArray);
            }
        });
    });
}

@end
