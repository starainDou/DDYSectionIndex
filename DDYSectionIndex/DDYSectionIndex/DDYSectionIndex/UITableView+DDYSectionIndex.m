#import "UITableView+DDYSectionIndex.h"
#import <objc/runtime.h>
#import "DDYSectionIndex.h"

static BOOL isUseCustomIndex;


@interface UITableView ()

@property (nonatomic, strong) DDYSectionIndex *indexView;

@end

@implementation UITableView (DDYSectionIndex)

- (DDYSectionIndex *)indexView {
    DDYSectionIndex *indexView = objc_getAssociatedObject(self, @selector(indexView));
    if (!indexView) {
        indexView = [[DDYSectionIndex alloc] init];
        objc_setAssociatedObject(self, @selector(setIndexView:), indexView, objc_AssociationPolicy policy)
    }
    return indexView;
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self changeOrignalSEL:@selector(setDelegate:) swizzleSEL:@selector(ddy_SetDelegate:)];
        [self changeOrignalSEL:@selector(didMoveToSuperview) swizzleSEL:@selector(ddy_DidMoveToSuperview)];
        [self changeOrignalSEL:@selector(removeFromSuperview) swizzleSEL:@selector(ddy_RemoveFromSuperview)];
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

- (void)ddy_SetDelegate:(id<UITableViewDelegate>)delegate {
    SEL oldSelector = @selector(sectionIndexTitlesForTableView:);
    SEL newSelector = @selector(ddy_SectionIndexTitlesForTableView:);
    Method oldMethod_del = class_getInstanceMethod([delegate class], oldSelector);
    Method oldMethod_self = class_getInstanceMethod([self class], oldSelector);
    Method newMethod = class_getInstanceMethod([self class], newSelector);
    
    // 若未实现代理方法，则先添加代理方法
    BOOL isSuccess = class_addMethod([delegate class], oldSelector, class_getMethodImplementation([self class], newSelector), method_getTypeEncoding(newMethod));
    if (isSuccess) {
        class_replaceMethod([delegate class], newSelector, class_getMethodImplementation([self class], oldSelector), method_getTypeEncoding(oldMethod_self));
    } else {
        // 若已实现代理方法，则添加 hook 方法并进行交换
        BOOL isVictory = class_addMethod([delegate class], newSelector, class_getMethodImplementation([delegate class], oldSelector), method_getTypeEncoding(oldMethod_del));
        if (isVictory) {
            class_replaceMethod([delegate class], oldSelector, class_getMethodImplementation([self class], newSelector), method_getTypeEncoding(newMethod));
        }
    }
    [self ddy_SetDelegate:delegate];
}

- (NSArray *)ddy_SectionIndexTitlesForTableView:(UITableView *)tableView {
    NSArray *titleArray = [self ddy_SectionIndexTitlesForTableView:tableView];
    if (isUseCustomIndex) {
        
        return nil;
    }
    return titleArray;
}

- (void)ddy_DidMoveToSuperview {
    [self ddy_DidMoveToSuperview];
}

- (void)ddy_RemoveFromSuperview {
    
    [self ddy_RemoveFromSuperview];
}


@end
