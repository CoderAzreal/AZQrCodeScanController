//
//  AZSwiftQrCodeCapture.swift
//  AZSwiftQrCodeCapture
//
//  Created by tianfengyu on 2017/5/21.
//  Copyright © 2017年 tianfengyu. All rights reserved.
//

import UIKit
import AVFoundation

let AZ_screenWidth: CGFloat = UIScreen.main.bounds.width
let AZ_screenHeight: CGFloat = UIScreen.main.bounds.height
let scanImageLeftPadding: CGFloat = 50.0

public class AZSwiftQrCodeScanController: UIViewController {
    
    // MARK: - 属性定义
    
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
    
    /// 导航栏文字、按钮颜色 默认白色
    public var navigationTintColor: UIColor = UIColor.white
    
    /// 导航栏透明度 默认为0 透明
    public var navigationBarAlpha: CGFloat = 0
    
    /// 导航栏背景颜色 默认白色
    public var navigationBarTintColor: UIColor = UIColor.white
    
    /// 导航栏标题 默认为“二维码扫描”
    public var navigationTitleText = "二维码扫描"
    
    /// 导航栏
    fileprivate var navigationBar: UINavigationBar?
    
    /// 扫码框位置
    fileprivate var scanFrame: CGRect!
    
    /// 扫码完成回调
    fileprivate var complete: ((String)->())?
    
    fileprivate var device: AZSwiftQrCodeScanDevice?
    fileprivate var scanView: AZSwiftQrCodeScanView!
    
    // MARK: - 初始化方法定义
    
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
        scanView = AZSwiftQrCodeScanView(scanFrame: self.scanFrame)
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
        scanView = AZSwiftQrCodeScanView(scanFrame: self.scanFrame)
        self.complete = complete
    }
    
    private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(scanView)
        requestCaptureAuth()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configNavigation()
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

// MARK: - 导航栏
extension AZSwiftQrCodeScanController {
    
    fileprivate func configNavigation() {
        // 创建导航栏
        if navigationController == nil {
            // 创建导航栏view
            navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: AZ_screenWidth, height: 64))
            navigationBar?.shadowImage = UIImage()
            navigationBar?.setBackgroundImage(UIImage.colorImage(color: navigationBarTintColor, alpha: navigationBarAlpha), for: .default)
            navigationBar?.tintColor = navigationTintColor
            let navigationItem = UINavigationItem(title: navigationTitleText)
            navigationBar?.pushItem(navigationItem, animated: true)
            let bundlePath = Bundle(for: self.classForCoder).path(forResource: "AZQrCode", ofType: "bundle")!
            let imagePath = Bundle(path: bundlePath)!.path(forResource: "close@2x", ofType: "png")!
            let image = UIImage(contentsOfFile: imagePath)?.withRenderingMode(.alwaysTemplate)
            let closeItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(dismissController))
            navigationItem.leftBarButtonItem = closeItem
            navigationBar?.titleTextAttributes = [NSForegroundColorAttributeName: navigationTintColor]
//            let albumItem = UIBarButtonItem(title: "相册", style: .plain, target: self, action: #selector(albumClick))
//            navigationItem.rightBarButtonItem = albumItem
            view.addSubview(navigationBar!)
        } else {
            navigationItem.title = navigationTitleText
            navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: navigationTintColor]
//            let albumItem = UIBarButtonItem(title: "相册", style: .plain, target: self, action: #selector(albumClick))
//            navigationItem.rightBarButtonItem = albumItem
            navigationController?.navigationBar.tintColor = navigationTintColor
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.setBackgroundImage(UIImage.colorImage(color: navigationBarTintColor, alpha: navigationBarAlpha), for: .default)
        }
    }
    
    func albumClick() {
        
    }
    
    func dismissController() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - 请求用户权限
extension AZSwiftQrCodeScanController {
    
    fileprivate func requestCaptureAuth() {
        //
        func deviceWork() {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                device = AZSwiftQrCodeScanDevice(scanFrame: scanFrame, layer: view.layer)
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
                    DispatchQueue.main.async {
                        deviceWork()
                    }
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
}
// MARK: - 生成纯色图片
private extension UIImage {
    
    static func colorImage(color: UIColor, alpha: CGFloat) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.setAlpha(alpha)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

