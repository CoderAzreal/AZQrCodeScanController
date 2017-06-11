//
//  AZQrCodeCapture.swift
//  AZQrCodeCapture
//
//  Created by tianfengyu on 2017/5/21.
//  Copyright © 2017年 tianfengyu. All rights reserved.
//

import UIKit
import AVFoundation

private let AZ_screenWidth = UIScreen.main.bounds.width
private let AZ_screenHeight = UIScreen.main.bounds.height
private let scanImageLeftPadding: CGFloat = 50.0

public class AZQrCodeScanController: UIViewController {
    
    /// 扫码线图片
    public var scanLineImage: UIImage? { didSet { scanView.scanLine.image = scanLineImage } }
    
    /// 扫码框图片
    public var scanImage: UIImage? { didSet { scanView.scanImageView.image = scanImage } }
    
    /// 扫码框和扫码线颜色
    public var tintColor: UIColor! { didSet {
        scanView.scanImageView.tintColor = scanColor
        scanView.scanLine.tintColor = scanColor
        } }
    
    /// 单独设置扫码框颜色
    public var scanColor: UIColor! { didSet { scanView.scanImageView.tintColor = scanColor } }
    
    /// 单独设置扫码线颜色
    public var scanLineColor: UIColor! { didSet { scanView.scanLine.tintColor = scanLineColor } }
    
    /// 遮罩层透明度
    public var coverViewAlpha: CGFloat! { didSet {
        for item in [scanView.topCoverView, scanView.leftCoverView, scanView.bottomCoverView, scanView.rightCoverView] {
            item.alpha = coverViewAlpha
        } } }
    
    /// 提示文字
    public var introduceText: String? { didSet { scanView.introduceLabel.text = introduceText } }
    
    /// 提示文字字体大小
    public var introduceFontSize: CGFloat! { didSet {
        scanView.introduceLabel.font = UIFont.systemFont(ofSize: introduceFontSize)
        scanView.introduceLabel.sizeToFit()
        } }
    
    /// 提示文字字体
    public var introduceFont: UIFont! { didSet {
        scanView.introduceLabel.font = introduceFont
        scanView.introduceLabel.sizeToFit()
        } }
    
    /// 提示文字颜色
    public var introduceTextColor: UIColor! { didSet { scanView.introduceLabel.textColor = introduceTextColor } }
    
    /// 提示文字位置
    public var introduceFrame: CGRect! { didSet { scanView.introduceLabel.frame = introduceFrame } }
    
    /// 无拍照权限时提示的appname
    public var appName: String?
    
    
    /// 扫码框位置
    private var scanFrame: CGRect!
    
    /// 扫码完成回调
    private var complete: ((String)->())?
    
    private var device: AZQrCodeScanDevice?
    private var scanView: AZQrCodeScanView!
    
    /// 初始化方法 默认扫码区域为屏幕宽度-100 居中显示
    ///
    /// - Parameter scanComplete: 扫码完成后回调
    public convenience init(scanComplete: ((String)->())?) {
        self.init(nibName: nil, bundle: nil)
        let width = AZ_screenWidth-scanImageLeftPadding*2
        self.scanFrame = CGRect(x: (AZ_screenWidth-width)/2,
                                y: (AZ_screenHeight-width)/2,
                                width: width,
                                height: width)
        scanView = AZQrCodeScanView(scanFrame: self.scanFrame)
        self.complete = scanComplete
    }
    
    /// 初始化方法
    ///
    /// - Parameters:
    ///   - scanFrame: 自定义扫码区域
    ///   - complete: 扫码完成回调
    public convenience init(scanFrame: CGRect, complete: ((String)->())?) {
        self.init(nibName: nil, bundle: nil)
        self.scanFrame = scanFrame
        scanView = AZQrCodeScanView(scanFrame: self.scanFrame)
        self.complete = complete
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(scanView)
        requestCaptureAuth()
    }
    
    private func requestCaptureAuth() {
        
        func deviceWork() {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                device = AZQrCodeScanDevice(scanFrame: scanFrame, layer: view.layer)
                device?.complete = complete
            } else {
                showPrompt(text: "当前设备没有拍照功能")
            }
        }
        
        weak var wkSelf = self
        
        let state = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch state {
        case .notDetermined:
            // 用户还没有决定是否给相机授权
            
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) {
                let ws = wkSelf!
                if $0 {
                    deviceWork()
                } else {
                    // 用户拒绝
                    ws.showPrompt()
                }
            }
        case .denied, .restricted:
            // 用户拒绝相机授权
            showPrompt()
        case .authorized:
            // 用户同意授权
            deviceWork()
        }
    }
    
    private func showPrompt(text: String? = nil) {
        scanView.isHidden = true
        
        let promptLabel = UILabel(frame: CGRect(x: 20, y: 0, width: AZ_screenWidth-40, height: 300))
        promptLabel.textAlignment = .center
        if appName == nil {
            appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
            if appName == nil {
                appName = Bundle.main.infoDictionary?["CFBundleName"] as? String
            }
            if appName == nil {
                appName = "本app"
            }
        }
        promptLabel.text = text ?? "请在iPhone的\"设置-隐私-相机\"中允许\(appName!)访问您的相机"
        promptLabel.numberOfLines = 0
        view.addSubview(promptLabel)
        
    }
    
    private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        if device != nil && device!.session.isRunning {
            device!.session.stopRunning()
        }
        if !scanView.timer.isCancelled {
            scanView.timer.cancel()
        }
    }
}

private class AZQrCodeScanView: UIView {
    var topCoverView = UIView()
    var leftCoverView = UIView()
    var rightCoverView = UIView()
    var bottomCoverView = UIView()
    
    fileprivate var scanFrame: CGRect!
    
    var scanImageView: UIImageView! // 扫码框
    var scanLine: UIImageView! // 扫码线
    var introduceLabel: UILabel! // 提示文字label
    
    
    /// 扫码线移动方向
    private enum LineMoveDirect {
        case up
        case down
    }
    var timer: DispatchSourceTimer!
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
            switch wkSelf!.lineDirection {
            case .up:
                lineFrame.origin.y -= 1
            case .down:
                lineFrame.origin.y += 1
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
        
        let bundlePath = Bundle.main.path(forResource: "AZQrCode", ofType: "bundle")!
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

private class AZQrCodeScanDevice: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    
    private var device: AVCaptureDevice!
    private var input: AVCaptureDeviceInput!
    private var output: AVCaptureMetadataOutput!
    var session: AVCaptureSession!
    private var preview: AVCaptureVideoPreviewLayer!
    var complete: ((String)->())?
    
    init(scanFrame: CGRect, layer: CALayer) {
        super.init()
        device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        do {
            input = try AVCaptureDeviceInput(device: device)
        } catch {
            print(error)
        }
        output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: .main)
        
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetHigh
        if session.canAddInput(input) {
            session.addInput(input)
        }
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]
        output.rectOfInterest = CGRect(x: scanFrame.origin.y/AZ_screenHeight,
                                       y: (AZ_screenWidth-scanFrame.size.width-scanFrame.origin.x)/AZ_screenWidth,
                                       width: scanFrame.size.height/AZ_screenHeight,
                                       height: scanFrame.size.width/AZ_screenWidth)
        preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill
        preview.frame = CGRect(x: 0, y: 0, width: AZ_screenWidth, height: AZ_screenHeight)
        layer.insertSublayer(preview, at: 0)
        session.startRunning()
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if metadataObjects.count > 0 {
            session.stopRunning()
            let metadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            let stringValue = metadataObject.stringValue
            guard stringValue != nil else {
                complete?("")
                return
            }
            complete?(stringValue!)
        }
    }
}
