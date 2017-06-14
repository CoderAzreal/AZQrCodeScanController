//
//  AZSwiftQrCodeScanDevice.swift
//  AZQrCodeScanController
//
//  Created by tianfengyu on 2017/6/13.
//  Copyright © 2017年 Azreal. All rights reserved.
//

import AVFoundation

class AZSwiftQrCodeScanDevice: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    
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
