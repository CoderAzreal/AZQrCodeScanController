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
        NSLog(@"result");
    }];
    [self presentViewController:c animated:true completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
