#import <Foundation/Foundation.h>
#import "DDYCategoryHeader.h"

@interface DDYIndexModel : NSObject

@property (nonatomic, strong) NSString *title;

+ (NSArray <DDYIndexModel *>*)testModelArray;

@end

/** 排序根据selector来 */
