#import "ViewController.h"
#import "DDYSectionIndexSystem.h"

#ifndef DDYTopH
#define DDYTopH (self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height)
#endif

#ifndef DDYScreenW
#define DDYScreenW [UIScreen mainScreen].bounds.size.width
#endif

#ifndef DDYScreenH
#define DDYScreenH [UIScreen mainScreen].bounds.size.height
#endif

@interface ViewController ()<UITextViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:[self btnY: 50 tag:100 title:@"System"]];
    [self.view addSubview:[self btnY:100 tag:101 title:@"Custom"]];
    [self.view addSubview:[self btnY:150 tag:102 title:@"Custom_Search"]];
    [self.view addSubview:[self btnY:200 tag:103 title:@"Custom_right"]];
    [self.view addSubview:[self btnY:250 tag:104 title:@"Customh_Center"]];
    [self.view addSubview:[self btnY:300 tag:105 title:@"Custom_Search_right"]];
    [self.view addSubview:[self btnY:350 tag:106 title:@"Custom_Search_Center"]];
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
    if (sender.tag == 100) {
        [self.navigationController pushViewController:[[DDYSectionIndexSystem alloc] init] animated:YES];
    } else if (sender.tag == 101) {
        [self.navigationController pushViewController:[[DDYSectionIndexSystem alloc] init] animated:YES];
    } else if (sender.tag == 102) {
        [self.navigationController pushViewController:[[DDYSectionIndexSystem alloc] init] animated:YES];
    } else if (sender.tag == 103) {
        [self.navigationController pushViewController:[[DDYSectionIndexSystem alloc] init] animated:YES];
    } else if (sender.tag == 104) {
        [self.navigationController pushViewController:[[DDYSectionIndexSystem alloc] init] animated:YES];
    } else if (sender.tag == 105) {
        [self.navigationController pushViewController:[[DDYSectionIndexSystem alloc] init] animated:YES];
    } else if (sender.tag == 106) {
        [self.navigationController pushViewController:[[DDYSectionIndexSystem alloc] init] animated:YES];
    }
}

@end

/** [[DDYEmitterFire alloc] init] 不可用[DDYEmitterFire new]替代，原因自行测试 */
