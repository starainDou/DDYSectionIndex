#import <Foundation/Foundation.h>

@interface NSArray (DDYExtension)

/**
 对模型数组进行索引排序
 @param selector 模型排序依据属性
 @param complete 完成后回调
 */
- (void)ddy_ModelSortSelector:(SEL)selector complete:(void (^)(NSArray *modelsArray, NSArray *titlesArray))complete;

@end
