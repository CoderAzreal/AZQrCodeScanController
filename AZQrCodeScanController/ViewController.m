//
//  ViewController.m
//  AZQrCodeScanController
//
//  Created by tianfengyu on 2017/6/9.
//  Copyright © 2017年 Azreal. All rights reserved.
//

#import "ViewController.h"
#import "AZQrCodeScanController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    AZQrCodeScanController *c = [[AZQrCodeScanController alloc] initWithScanComplete:^(NSString *result) {
        NSLog(@"%@", result);
        [self dismissViewControllerAnimated:true completion:nil];
    }];
    
//    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:c];
//    c.navigationTitleText = @"扫描";
//    c.navigationBarAlpha = 0.5;
//    c.navigationBarTintColor = UIColor.redColor;
//    c.navigationTintColor = UIColor.greenColor;

    [self presentViewController:c animated:true completion:nil];
}


@end
