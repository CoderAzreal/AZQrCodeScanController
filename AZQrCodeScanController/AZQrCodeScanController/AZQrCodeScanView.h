//
//  AZQrCodeScanView.h
//  AZQrCodeScanController
//
//  Created by tianfengyu on 2017/6/9.
//  Copyright © 2017年 Azreal. All rights reserved.
//

#import <UIKit/UIKit.h>



typedef NS_ENUM(NSUInteger, AZTimerState) {
    AZTimerStateMove,
    AZTimerStateStop
};

@interface AZQrCodeScanView : UIView

@property (nonatomic, strong) dispatch_source_t timer;

@property (nonatomic, strong) UIView *topCoverView;
@property (nonatomic, strong) UIView *leftCoverView;
@property (nonatomic, strong) UIView *rightCoverView;
@property (nonatomic, strong) UIView *bottomCoverView;

@property (nonatomic, strong) UIImageView *scanImageView;
@property (nonatomic, strong) UIImageView *scanLine;
@property (nonatomic, strong) UILabel *introduceLabel;
@property (nonatomic, assign) AZTimerState timerState;

- (instancetype)initWithScanFrame:(CGRect)scanFrame;

@end
