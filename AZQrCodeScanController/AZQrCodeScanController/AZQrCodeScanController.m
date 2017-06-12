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
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIColor *closeButtonTintColor;

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
    _closeButtonTintColor = UIColor.whiteColor;
    [self requestCaptureAuth];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self isBeingPresented] && self.navigationController == nil) {
        // 如果是present出来的
        [self addReturnButton];
    }
    
}

- (void)dealloc {
    if (_device && _device.session.isRunning) {
        [_device.session stopRunning];
    }
    dispatch_source_cancel(_scanView.timer);
}

- (void)addReturnButton {
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *bundlePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"AZQrCode" ofType:@"bundle"];
    NSString *imagePath = [[NSBundle bundleWithPath:bundlePath] pathForResource:@"close@2x" ofType:@"png"];
    UIImage *image = [[UIImage imageWithContentsOfFile:imagePath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_closeButton setImage:image forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(dismissController) forControlEvents:UIControlEventTouchUpInside];
    _closeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _closeButton.frame = CGRectMake(15, 20, 50, 44);
    _closeButton.imageView.tintColor = _closeButtonTintColor;
    [self.view addSubview:_closeButton];
}

- (void)dismissController {
    [self dismissViewControllerAnimated:true completion:nil];
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
                        [wkSelf deviceWork];
                    } else {
                        // 用户拒绝
                        [wkSelf showPrompt:nil];
                    }
                });
            }];
        }
            break;
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            // 用户拒绝相机授权或没有相机权限
            [self showPrompt:nil];
            break;
        case AVAuthorizationStatusAuthorized:
            // 授权
            [self deviceWork];
            break;
    }
}

- (void)deviceWork {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        _device = [[AZQrCodeScanDevice alloc] initWithScanFrame:_scanFrame layer:self.view.layer];
        _device.complete = _scanCompleteBlock;
    } else {
        [self showPrompt:@"当前设备没有拍照功能"];
    }
    
}

- (void)showPrompt:(NSString *)text {
    
    _scanView.hidden = true;
    _closeButtonTintColor = UIColor.blackColor;
    UILabel *promptView = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, AZ_SCREENWIDTH-40, 300)];
    promptView.textAlignment = NSTextAlignmentCenter;
    
    NSString *promptText = nil;
    if (text == nil) {
        if (!_appName) {
            _appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"] ?
            [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"] :
            [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
        }
        promptText = [NSString stringWithFormat:@"请在iPhone的\"设置-隐私-相机\"中允许%@访问您的相机", _appName];
    } else {
        promptText = text;
    }
    promptView.text = promptText;
    promptView.numberOfLines = 0;
    [self.view addSubview:promptView];
    
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

- (void)setShowCloseButton:(BOOL)showCloseButton {
    _showCloseButton = showCloseButton;
    _closeButton.hidden = true;
}

@end
