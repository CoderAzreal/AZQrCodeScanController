//
//  AZQrCodeScanController.m
//  AZQrCodeScanController
//
//  Created by tianfengyu on 2017/6/9.
//  Copyright © 2017年 Azreal. All rights reserved.
//

#import "AZQrCodeScanController.h"
#import "AZQrCodeScanView.h"
#import "AZQrCodeScanDevice.h"

#define AZ_SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define AZ_SCREENHEIGHT [UIScreen mainScreen].bounds.size.height
#define SCANPADDING 50

@interface AZQrCodeScanController ()

@property (nonatomic, assign) CGRect scanFrame;
@property (nonatomic, strong) AZQrCodeScanDevice *device;
@property (nonatomic, strong) AZQrCodeScanView *scanView;
@property (nonatomic, copy) void(^scanCompleteBlock)(NSString *result);

@end

@implementation AZQrCodeScanController

// MARK: - 初始化方法
- (instancetype)initWithScanComplete:(void (^)(NSString *))complete {
    
    if (self = [super init]) {
        CGFloat width = AZ_SCREENWIDTH - SCANPADDING*2;
        _scanFrame = CGRectMake((AZ_SCREENWIDTH-width)/2,
                                (AZ_SCREENHEIGHT-width)/2,
                                width,
                                width);
        _scanView = [[AZQrCodeScanView alloc] initWithScanFrame:_scanFrame];
        _scanCompleteBlock = complete;
    }
    return self;
}

- (instancetype)initWithScanFrame:(CGRect)frame complete:(void (^)(NSString *))complete {
    
    if (self = [super init]) {
        _scanFrame = frame;
        _scanView = [[AZQrCodeScanView alloc] initWithScanFrame:_scanFrame];
        _scanCompleteBlock = complete;
    }
    return self;
}

// MARK: - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:_scanView];
    
    [self requestCaptureAuth];
    
}

- (void)requestCaptureAuth {
    __weak AZQrCodeScanController *wkSelf = self;
    
    AVAuthorizationStatus state = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (state) {
        case AVAuthorizationStatusNotDetermined: {
            // 用户还没有决定是否给相机授权
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        // 用户接受
                        wkSelf.device = [[AZQrCodeScanDevice alloc] initWithScanFrame:_scanFrame layer:wkSelf.view.layer];
                        wkSelf.device.complete = wkSelf.scanCompleteBlock;
                    } else {
                        // 用户拒绝
                        [wkSelf showPrompt];
                    }
                });
            }];
        }
            break;
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            // 用户拒绝相机授权或没有相机权限
            [self showPrompt];
            break;
        case AVAuthorizationStatusAuthorized:
            // 授权
            _device = [[AZQrCodeScanDevice alloc] initWithScanFrame:_scanFrame layer:self.view.layer];
            _device.complete = _scanCompleteBlock;
            break;
    }
}

- (void)showPrompt {
    
    _scanView.hidden = true;
    
    UILabel *promptView = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, AZ_SCREENWIDTH-40, 300)];
    promptView.textAlignment = NSTextAlignmentCenter;
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    if (!appName) {
        appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    }
    promptView.text = [NSString stringWithFormat:@"请在iPhone的\"设置-隐私-相机\"中允许%@访问您的相机", appName];
    promptView.numberOfLines = 0;
    [self.view addSubview:promptView];

}

- (void)dealloc {
    if (_device && _device.session.isRunning) {
        [_device.session stopRunning];
    }
    dispatch_source_cancel(_scanView.timer);
}

// MARK: - Set
- (void)setScanLineImage:(UIImage *)scanLineImage {
    _scanLineImage = scanLineImage;
    _scanView.scanLine.image = scanLineImage;
}

- (void)setScanImage:(UIImage *)scanImage {
    _scanImage = scanImage;
    _scanView.scanImageView.image = scanImage;
}

- (void)setTintColor:(UIColor *)tintColor {
    _tintColor = tintColor;
    _scanView.scanImageView.tintColor = tintColor;
    _scanView.scanLine.tintColor = tintColor;
}

- (void)setScanColor:(UIColor *)scanColor {
    _scanColor = scanColor;
    _scanView.scanImageView.tintColor = scanColor;
}

- (void)setScanLineColor:(UIColor *)scanLineColor {
    _scanLineColor = scanLineColor;
    _scanView.scanLine.tintColor = scanLineColor;
}

- (void)setCoverViewAlpha:(CGFloat)coverViewAlpha {
    _coverViewAlpha = coverViewAlpha;
    for (UIView *item in @[_scanView.topCoverView, _scanView.leftCoverView, _scanView.bottomCoverView, _scanView.rightCoverView]) {
        item.alpha = coverViewAlpha;
    }
}

- (void)setIntroduceText:(NSString *)introduceText {
    _introduceText = introduceText;
    _scanView.introduceLabel.text = introduceText;
}

- (void)setIntroduceFontSize:(CGFloat)introduceFontSize {
    _introduceFontSize = introduceFontSize;
    _scanView.introduceLabel.font = [UIFont systemFontOfSize:introduceFontSize];
    [_scanView.introduceLabel sizeToFit];
}

- (void)setIntroduceFont:(UIFont *)introduceFont {
    _introduceFont = introduceFont;
    _scanView.introduceLabel.font = introduceFont;
    [_scanView.introduceLabel sizeToFit];
}

- (void)setIntroduceTextColor:(UIColor *)introduceTextColor {
    _introduceTextColor = introduceTextColor;
    _scanView.introduceLabel.textColor = introduceTextColor;
}

- (void)setIntroduceFrame:(CGRect)introduceFrame {
    _introduceFrame = introduceFrame;
    _scanView.introduceLabel.frame = introduceFrame;
}

@end
