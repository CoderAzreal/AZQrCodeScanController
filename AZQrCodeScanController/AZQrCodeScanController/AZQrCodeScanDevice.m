//
//  AZQrCodeScanDevice.m
//  AZQrCodeScanController
//
//  Created by tianfengyu on 2017/6/9.
//  Copyright © 2017年 Azreal. All rights reserved.
//

#import "AZQrCodeScanDevice.h"


#define AZ_SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define AZ_SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

@interface AZQrCodeScanDevice () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preview;

@end

@implementation AZQrCodeScanDevice

- (instancetype)initWithScanFrame:(CGRect)frame layer:(CALayer *)layer {
    if (self = [super init]) {
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        NSError *error = nil;
        _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
        
        _output = [[AVCaptureMetadataOutput alloc] init];
        [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        _session = [[AVCaptureSession alloc] init];
        _session.sessionPreset = AVCaptureSessionPresetHigh;
        
        if ([_session canAddInput:_input]) {
            [_session addInput:_input];
        }
        if ([_session canAddOutput:_output]) {
            [_session addOutput:_output];
        }
        
        _output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
        
        _output.rectOfInterest = CGRectMake(frame.origin.y/AZ_SCREENHEIGHT,
                                            (AZ_SCREENWIDTH-frame.size.width-frame.origin.x)/AZ_SCREENWIDTH,
                                            frame.size.height/AZ_SCREENHEIGHT,
                                            frame.size.width/AZ_SCREENWIDTH);
        _preview = [AVCaptureVideoPreviewLayer layerWithSession:_session];
        _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _preview.frame = CGRectMake(0, 0, AZ_SCREENWIDTH, AZ_SCREENHEIGHT);
        [layer insertSublayer:_preview atIndex:0];
        [_session startRunning];
        
    }
    return self;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count > 0) {
        [_session stopRunning];
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects[0];
        NSString *stringValue = metadataObject.stringValue;
        if (stringValue) {
            _complete(stringValue);
        }
    }
}

@end
