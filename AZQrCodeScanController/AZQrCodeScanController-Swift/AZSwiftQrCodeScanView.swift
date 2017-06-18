//
//  AZSwiftQrCodeScanView.swift
//  AZQrCodeScanController
//
//  Created by tianfengyu on 2017/6/13.
//  Copyright © 2017年 Azreal. All rights reserved.
//

import UIKit

class AZSwiftQrCodeScanView: UIView {
    var topCoverView = UIView()
    var leftCoverView = UIView()
    var rightCoverView = UIView()
    var bottomCoverView = UIView()
    
    fileprivate var scanFrame: CGRect!
    
    var scanImageView: UIImageView! // 扫码框
    var scanLine: UIImageView! // 扫码线
    var introduceLabel: UILabel! // 提示文字label
    
    enum AZTimerState {
        case move
        case stop
    }
    /// 扫码线移动方向
    private enum LineMoveDirect {
        case up
        case down
    }
    var timer: DispatchSourceTimer!
    var timerState = AZTimerState.move
    private var lineDirection = LineMoveDirect.down
    
    convenience init(scanFrame: CGRect) {
        self.init(frame: CGRect(x: 0, y: 0, width: AZ_screenWidth, height: AZ_screenHeight))
        configCoverView()
        
        self.scanFrame = scanFrame
        resetCoverViewFrame()
        configScanUI()
        configTimer()
    }
    
    /// 扫码线移动
    private func configTimer() {
        timer = DispatchSource.makeTimerSource(flags: .strict, queue: .main)
        timer.scheduleRepeating(deadline: .now(), interval: .milliseconds(10))
        weak var wkSelf = self
        timer.setEventHandler {
            var lineFrame = wkSelf!.scanLine.frame
            switch wkSelf!.timerState {
            case .move:
                switch wkSelf!.lineDirection {
                case .up:
                    lineFrame.origin.y -= 1
                case .down:
                    lineFrame.origin.y += 1
                }
            case .stop:
                lineFrame.origin.y = wkSelf!.scanFrame.origin.y
            }
            
            wkSelf?.scanLine.frame = lineFrame
            if lineFrame.origin.y >= wkSelf!.scanFrame.origin.y + wkSelf!.scanFrame.width - lineFrame.size.height {
                wkSelf!.lineDirection = .up
            } else if lineFrame.origin.y <= wkSelf!.scanFrame.origin.y {
                wkSelf!.lineDirection = .down
            }
        }
        timer.resume()
    }
    
    /// 扫码框/扫码线/介绍文字
    private func configScanUI() {
        
        let bundlePath = Bundle(for: classForCoder).path(forResource: "AZQrCode", ofType: "bundle")!
        let captureBundle = Bundle(path: bundlePath)!
        
        scanImageView = UIImageView(frame: scanFrame)
        let bgPath = captureBundle.path(forResource: "scan_bg_pic@2x", ofType: "png")!
        scanImageView.image = UIImage(contentsOfFile: bgPath)
        addSubview(scanImageView)
        
        scanLine = UIImageView(frame: CGRect(x: scanFrame.origin.x, y: scanFrame.origin.y
            , width: scanFrame.width, height: 2))
        let linePath = captureBundle.path(forResource: "scan_line@2x", ofType: "png")!
        scanLine.image = UIImage(contentsOfFile: linePath)
        addSubview(scanLine)
        
        introduceLabel = UILabel(frame: CGRect(x: scanFrame.origin.x, y: scanFrame.origin.y+scanFrame.size.height+20, width: scanFrame.width, height: 40))
        introduceLabel.numberOfLines = 0
        introduceLabel.textAlignment = .center
        introduceLabel.text = "将二维码/条码放入框内，即可自动扫描。"
        introduceLabel.textColor = .white
        introduceLabel.font = UIFont.systemFont(ofSize: 14)
        addSubview(introduceLabel)
    }
    
    /// 配置coverView
    private func configCoverView() {
        for item in [topCoverView, leftCoverView, bottomCoverView, rightCoverView] {
            item.backgroundColor = UIColor(white: 0, alpha: 0.4)
            addSubview(item)
        }
    }
    
    /// 设置遮罩层位置
    private func resetCoverViewFrame() {
        leftCoverView.frame = CGRect(x: 0, y: 0, width: scanFrame.origin.x, height: AZ_screenHeight)
        topCoverView.frame = CGRect(x: scanFrame.origin.x, y: 0, width: AZ_screenWidth, height: scanFrame.origin.y)
        rightCoverView.frame = CGRect(x: scanFrame.origin.x, y: scanFrame.height+scanFrame.origin.y, width: AZ_screenWidth, height: AZ_screenHeight)
        bottomCoverView.frame = CGRect(x: scanFrame.width+scanFrame.origin.x, y: scanFrame.origin.y, width: AZ_screenWidth, height: scanFrame.height)
    }
    
    
    override init(frame: CGRect) { super.init(frame: frame) }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
