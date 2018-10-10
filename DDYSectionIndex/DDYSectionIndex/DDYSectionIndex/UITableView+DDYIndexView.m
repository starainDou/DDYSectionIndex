
#import "UITableView+DDYIndexView.h"
#import <objc/runtime.h>
#import "DDYIndexView.h"

static BOOL isUseCustomIndex;

@interface DDYWeakProxy : NSObject
@property (nonatomic, weak) DDYIndexView *indexView;
@end
@implementation DDYWeakProxy
@end

@interface UITableView ()

@property (nonatomic, strong) DDYIndexView *ddy_IndexView;

@end

@implementation UITableView (DDYIndexView)

+ (void)load {
    [self changeOrignalSEL:@selector(setDelegate:)          swizzleSEL:@selector(ddy_SetDelegate:)];
    [self changeOrignalSEL:NSSelectorFromString(@"dealloc") swizzleSEL:@selector(ddy_Dealloc)];
    [self changeOrignalSEL:@selector(didMoveToSuperview)    swizzleSEL:@selector(ddy_DidMoveToSuperview)];
    [self changeOrignalSEL:@selector(removeFromSuperview)   swizzleSEL:@selector(ddy_RemoveFromSuperview)];
}

+ (void)changeOrignalSEL:(SEL)orignalSEL swizzleSEL:(SEL)swizzleSEL {
    Method originalMethod = class_getInstanceMethod([self class], orignalSEL);
    Method swizzleMethod  = class_getInstanceMethod([self class], swizzleSEL);
    if (class_addMethod([self class], orignalSEL, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod))) {
        class_replaceMethod([self class], swizzleSEL, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzleMethod);
    }
}

- (void)ddy_SetDelegate:(id<UITableViewDelegate>)delegate {
    SEL oldSelector         = @selector(sectionIndexTitlesForTableView:);
    SEL newSelector         = @selector(ddy_SectionIndexTitlesForTableView:);
    Method oldMethod_del    = class_getInstanceMethod([delegate class], oldSelector);
    Method oldMethod_self   = class_getInstanceMethod([self class], oldSelector);
    Method newMethod        = class_getInstanceMethod([self class], newSelector);
    
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

#pragma mark 拦截代理，如果开启自定义则不再显示系统
- (NSArray *)ddy_SectionIndexTitlesForTableView:(UITableView *)tableView {
    NSArray *titleArray = [self ddy_SectionIndexTitlesForTableView:tableView];
    return isUseCustomIndex ? nil : titleArray;
}

- (void)ddy_DidMoveToSuperview {
    [self ddy_DidMoveToSuperview];
    [self addIndexViewWithDataSource:self.ddy_IndexViewDataSource];
}

- (void)ddy_RemoveFromSuperview {
    if (self.ddy_IndexView) {
        [self.ddy_IndexView removeFromSuperview];
        self.ddy_IndexView = nil;
        isUseCustomIndex = NO;
    }
    [self ddy_RemoveFromSuperview];
}

- (DDYIndexView *)ddy_IndexView {
    DDYWeakProxy *weakProxy = objc_getAssociatedObject(self, @selector(ddy_IndexView));
    return weakProxy.indexView;
}

- (void)setDdy_IndexView:(DDYIndexView *)ddy_IndexView {
    if (self.ddy_IndexView == ddy_IndexView) return;
    DDYWeakProxy *weakProxy = [DDYWeakProxy new];
    weakProxy.indexView = ddy_IndexView;
    objc_setAssociatedObject(self, @selector(ddy_IndexView), weakProxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (DDYIndexViewConfig *)ddy_IndexViewConfig {
    DDYIndexViewConfig *ddy_IndexViewConfig = objc_getAssociatedObject(self, @selector(ddy_IndexViewConfig));
    if (!ddy_IndexViewConfig) ddy_IndexViewConfig = [DDYIndexViewConfig configWithIndexViewStyle:DDYIndexViewStyleRight];
    return ddy_IndexViewConfig;
}

- (void)setDdy_IndexViewConfig:(DDYIndexViewConfig *)ddy_IndexViewConfig {
    if (self.ddy_IndexViewConfig == ddy_IndexViewConfig) return;
    objc_setAssociatedObject(self, @selector(ddy_IndexViewConfig), ddy_IndexViewConfig, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray<NSString *> *)ddy_IndexViewDataSource {
    return objc_getAssociatedObject(self, @selector(ddy_IndexViewDataSource));
}

- (void)setDdy_IndexViewDataSource:(NSArray<NSString *> *)ddy_IndexViewDataSource {
    if (self.ddy_IndexViewDataSource == ddy_IndexViewDataSource) return;
    objc_setAssociatedObject(self, @selector(ddy_IndexViewDataSource), ddy_IndexViewDataSource, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self addIndexViewWithDataSource:ddy_IndexViewDataSource];
}

- (BOOL)ddy_ReplaceSystemSectionIndex {
    NSNumber *number = objc_getAssociatedObject(self, @selector(ddy_ReplaceSystemSectionIndex));
    return number.boolValue;
}

- (void)setDdy_ReplaceSystemSectionIndex:(BOOL)ddy_ReplaceSystemSectionIndex {
    objc_setAssociatedObject(self, @selector(ddy_ReplaceSystemSectionIndex), @(ddy_ReplaceSystemSectionIndex), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    isUseCustomIndex = ddy_ReplaceSystemSectionIndex;
}

- (BOOL)ddy_NavigationBarTranslucent {
    NSNumber *number = objc_getAssociatedObject(self, @selector(ddy_NavigationBarTranslucent));
    return number.boolValue;
}

- (void)setDdy_NavigationBarTranslucent:(BOOL)ddy_NavigationBarTranslucent {
    if (self.ddy_NavigationBarTranslucent == ddy_NavigationBarTranslucent) return;
    objc_setAssociatedObject(self, @selector(ddy_NavigationBarTranslucent), @(ddy_NavigationBarTranslucent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.ddy_IndexView.navigationBarTranslucent = ddy_NavigationBarTranslucent;
}

- (void)addIndexViewWithDataSource:(NSArray <NSString *>*)dataSource {
    if (!dataSource || dataSource.count == 0) {
        [self.ddy_IndexView removeFromSuperview];
        self.ddy_IndexView = nil;
        return;
    }
    if (!self.ddy_IndexView && self.superview) {
        DDYIndexView *indexView = [[DDYIndexView alloc] initWithTableView:self config:self.ddy_IndexViewConfig];
        indexView.navigationBarTranslucent = self.ddy_NavigationBarTranslucent;
        [self.superview addSubview:indexView];
        self.ddy_IndexView = indexView;
    }
    self.ddy_IndexView.dataSource = dataSource.copy;
}

- (void)ddy_Dealloc {
    isUseCustomIndex = NO;
}

@end
