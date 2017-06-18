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
    self.navigationItem.title = @"首页";
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"开始" forState:UIControlStateNormal];
    btn.frame = CGRectMake(100, 100, 100, 100);
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)btnClick {
    AZSwiftQrCodeScanController *c = [[AZSwiftQrCodeScanController alloc] initWithScanComplete:^(NSString *result, AZSwiftQrCodeScanController *capture) {
        
        /// 扫描后使用alert提示
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Result" message:result preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 再次启动
            [capture start];
        }]];
        [capture presentViewController:alert animated:false completion:nil];
        
        /// 扫码后推出新的控制器
        //        UIViewController *controller = [[UIViewController alloc] init];
        //        controller.view.backgroundColor = UIColor.whiteColor;
        //        [capture.navigationController pushViewController:controller animated:true];
        
        
    }];
    
    
    
    //    c.scanLineImage = [[UIImage alloc] init];
    //    c.scanImage = [[UIImage alloc] init];
    //    c.tintColor = UIColor.redColor;
    //    c.scanColor = UIColor.redColor;
    //    c.scanLineColor = UIColor.redColor;
    //    c.coverViewAlpha = 0.1;
    //    c.introduceText = @"可以自动扫描的哦";
    //    c.introduceFontSize = 18;
    //    c.introduceFont = [UIFont systemFontOfSize:12];
    //    c.introduceTextColor = UIColor.redColor;
    //    c.introduceFrame = CGRectMake(0, 0, 100, 100);
    //    c.appName = @"我是一个app";
    //    c.navigationTitleText = @"扫描";
    //    c.navigationBarAlpha = 0.5;
    //    c.navigationBarTintColor = UIColor.redColor;
    //    c.navigationTintColor = UIColor.greenColor;
    
    [self.navigationController pushViewController:c animated:true];
}


@end
