//
//  ViewController.m
//  AZQrCodeScanController
//
//  Created by tianfengyu on 2017/6/9.
//  Copyright © 2017年 Azreal. All rights reserved.
//

#import "ViewController.h"
#import "AZQrCodeScanController-Swift.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    AZSwiftQrCodeScanController *c = [[AZSwiftQrCodeScanController alloc] initWithScanComplete:^(NSString *result) {
        NSLog(@"%@", result);
        [self dismissViewControllerAnimated:true completion:nil];
    }];
    
//    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:c];
    c.appName = @"这个app";
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [c.view addSubview:button];
    [self presentViewController:c animated:true completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
