#import "UITableView+DDYSectionIndex.h"
#import <objc/runtime.h>

static BOOL isUseCustomIndex;

// !!!:--------------------------------------------------------
// MARK:表格分类
@implementation UITableView (DDYSectionIndex)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
    });
}

+ (void)changeOrignalSEL:(SEL)orignalSEL swizzleSEL:(SEL)swizzleSEL {
    Method originalMethod = class_getInstanceMethod([self class], orignalSEL);
    Method swizzleMethod = class_getInstanceMethod([self class], swizzleSEL);
    if (class_addMethod([self class], orignalSEL, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod))) {
        class_replaceMethod([self class], swizzleSEL, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzleMethod);
    }
}

- (UIColor *)ddy_SectionIndexColor {
    if (isUseCustomIndex) {
        return [self ddy_IndexBackgroundColor];
    } else {
        return [self ddy_SectionIndexColor];
    }
}

- (void)ddy_SetSectionIndexColor:(UIColor *)sectionIndexColor {
    if (isUseCustomIndex) {
        [self ddy_SetSectionIndexColor:sectionIndexColor];
    } else {
        [self ddy_SetSectionIndexColor:sectionIndexColor];
    }
}

- (UIColor *)ddy_IndexBackgroundColor {
    if (isUseCustomIndex) {
        return objc_getAssociatedObject(self, @selector(ddy_IndexBackgroundColor));
    } else {
        return [self ddy_SectionIndexColor];
    }
}

- (void)setDdy_IndexBackgroundColor:(UIColor *)ddy_IndexBackgroundColor {
    
}

@end
