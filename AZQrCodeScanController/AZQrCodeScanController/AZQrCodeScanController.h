//
//  AZQrCodeScanController.h
//  AZQrCodeScanController
//
//  Created by tianfengyu on 2017/6/9.
//  Copyright © 2017年 Azreal. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AZQrCodeScanControllerDelegate <NSObject>
/** 点击了右上角的相册按钮 */
- (void)onAZQrcodeAlbumButtonAction;
/** 二维码识别完成的回调 */
- (void)onAZQrcodeIdentifyComplete:(NSArray<NSString *> *)result;

@end

@protocol AZQrCodeScanControllerDataSource <NSObject>
/** 调用该方法识别图片中的二维码 */
- (void)az_scanThisQrcodeImage:(UIImage *)image;

@end

@interface AZQrCodeScanController : UIViewController <AZQrCodeScanControllerDataSource>

/**
 扫码线图片
 */
@property (nonatomic, strong) UIImage *scanLineImage;

/**
 扫码框图片
 */
@property (nonatomic, strong) UIImage *scanImage;

/**
 扫码框和扫码线颜色
 */
@property (nonatomic, strong) UIColor *tintColor;

/**
 单独设置扫码框颜色
 */
@property (nonatomic, strong) UIColor *scanColor;

/**
 单独设置扫码线颜色
 */
@property (nonatomic, strong) UIColor *scanLineColor;

/**
 遮罩层透明度
 */
@property (nonatomic, assign) CGFloat coverViewAlpha;

/**
 提示文字内容
 */
@property (nonatomic, copy) NSString *introduceText;

/**
 提示文字字体大小
 */
@property (nonatomic, assign) CGFloat introduceFontSize;

/**
 提示文字字体
 */
@property (nonatomic, strong) UIFont *introduceFont;

/**
 提示文字颜色
 */
@property (nonatomic, strong) UIColor *introduceTextColor;

/**
 提示文字位置
 */
@property (nonatomic, assign) CGRect introduceFrame;

/**
 无拍照权限时提示的appname
 */
@property (nonatomic, copy) NSString *appName;

/**
 导航栏文字、按钮颜色 默认白色
 */
@property (nonatomic, strong) UIColor *navigationTintColor;

/**
 导航栏透明度 默认为0 透明
 */
@property (nonatomic, assign) CGFloat navigationBarAlpha;

/**
 导航栏背景颜色 默认白色
 */
@property (nonatomic, strong) UIColor *navigationBarTintColor;

/**
 导航栏标题 默认为“二维码扫描”
 */
@property (nonatomic, copy) NSString *navigationTitleText;

@property (nonatomic, weak) id<AZQrCodeScanControllerDelegate> delegate;

/**
 初始化方法(默认扫码区宽高为屏幕宽度-100, 居中显示)
 
 @param complete 扫码成功后回调
 */
- (instancetype)initWithScanComplete:(void(^)(NSString *result, AZQrCodeScanController *capture))complete;

/**
 初始化方法

 @param frame 扫码区域位置
 @param complete 扫码成功后回调
 */
- (instancetype)initWithScanFrame:(CGRect)frame complete:(void(^)(NSString *result, AZQrCodeScanController *capture))complete;

- (void)start;
- (void)stop;

@end
