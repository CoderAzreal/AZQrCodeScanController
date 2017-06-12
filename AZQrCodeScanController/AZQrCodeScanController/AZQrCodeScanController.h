//
//  AZQrCodeScanController.h
//  AZQrCodeScanController
//
//  Created by tianfengyu on 2017/6/9.
//  Copyright © 2017年 Azreal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AZQrCodeScanController : UIViewController

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
 是否显示关闭按钮(只有当controller为present显示并且没有导航栏时有效)
 */
@property (nonatomic, assign) BOOL showCloseButton;

/**
 初始化方法(默认扫码区宽高为屏幕宽度-100, 居中显示)
 
 @param complete 扫码成功后回调
 */
- (instancetype)initWithScanComplete:(void(^)(NSString *result))complete;

/**
 初始化方法

 @param frame 扫码区域位置
 @param complete 扫码成功后回调
 */
- (instancetype)initWithScanFrame:(CGRect)frame complete:(void(^)(NSString *result))complete;

@end
