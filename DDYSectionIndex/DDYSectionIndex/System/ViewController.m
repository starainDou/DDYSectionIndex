#import "ViewController.h"
#import "DDYSectionIndexSystem.h"
#import "DDYSectionIndexCustom.h"

#ifndef DDYTopH
#define DDYTopH (self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height)
#endif

#ifndef DDYScreenW
#define DDYScreenW [UIScreen mainScreen].bounds.size.width
#endif

#ifndef DDYScreenH
#define DDYScreenH [UIScreen mainScreen].bounds.size.height
#endif

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:[self btnY: 50 tag:100 title:@"System"]];
    [self.view addSubview:[self btnY:100 tag:101 title:@"Custom_right"]];
    [self.view addSubview:[self btnY:150 tag:102 title:@"Customh_Center"]];
    [self.view addSubview:[self btnY:200 tag:103 title:@"Custom_Search_right"]];
    [self.view addSubview:[self btnY:250 tag:104 title:@"Custom_Search_Center"]];
    [self.view addSubview:[self btnY:300 tag:105 title:@"-"]];
    [self.view addSubview:[self btnY:350 tag:106 title:@"-"]];
}

- (UIButton *)btnY:(CGFloat)y tag:(NSUInteger)tag title:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor lightGrayColor]];
    [button setFrame:CGRectMake(10, DDYTopH + y, DDYScreenW-20, 40)];
    [button setTag:tag];
    [button addTarget:self action:@selector(handleBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    return button;
}

- (void)handleBtn:(UIButton *)sender {
//        CATransition* transition = [CATransition animation];
//        transition.duration = 0.25;
//        transition.type = kCATransitionMoveIn;
//        transition.subtype = kCATransitionFromTop;
//        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
//        [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    
    if (sender.tag == 100) {
        [self.navigationController pushViewController:[[DDYSectionIndexSystem alloc] init] animated:YES];
    } else if (sender.tag == 101) {
        DDYSectionIndexCustom *vc = [[DDYSectionIndexCustom alloc] init];
        vc.indexViewStyle = DDYIndexViewStyleRight;
        vc.hasSearch = NO;
        [self.navigationController pushViewController:vc animated:YES];
    } else if (sender.tag == 102) {
        DDYSectionIndexCustom *vc = [[DDYSectionIndexCustom alloc] init];
        vc.indexViewStyle = DDYIndexViewStyleCenter;
        vc.hasSearch = NO;
        [self.navigationController pushViewController:vc animated:YES];
    } else if (sender.tag == 103) {
        DDYSectionIndexCustom *vc = [[DDYSectionIndexCustom alloc] init];
        vc.indexViewStyle = DDYIndexViewStyleRight;
        vc.hasSearch = YES;
        [self.navigationController pushViewController:vc animated:YES];
    } else if (sender.tag == 104) {
        DDYSectionIndexCustom *vc = [[DDYSectionIndexCustom alloc] init];
        vc.indexViewStyle = DDYIndexViewStyleCenter;
        vc.hasSearch = YES;
        [self.navigationController pushViewController:vc animated:YES];
    } else if (sender.tag == 105) {
        [self.navigationController pushViewController:[[DDYSectionIndexSystem alloc] init] animated:YES];
    } else if (sender.tag == 106) {
        [self.navigationController pushViewController:[[DDYSectionIndexSystem alloc] init] animated:YES];
    }
}

@end
