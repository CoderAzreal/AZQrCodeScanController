Pod::Spec.new do |s|
s.name = "AZQrCodeScanController"
s.version = "1.1.2"
s.ios.deployment_target = '8.0'
s.summary = "iOS原生扫码控制器,导入时使用pod 'AZQrCodeScanController/swift' 或 pod 'AZQrCodeScanController/oc'"
s.homepage = "https://github.com/CoderAzreal/AZQrCodeScanController"
s.license = { :type => "MIT", :file => "LICENSE" }
s.author = {"AZReal" => "tianfengyu@foxmail.com" }
s.source = { :git => "https://github.com/CoderAzreal/AZQrCodeScanController.git", :tag => s.version }
s.requires_arc = true
s.dependency 'TZImagePickerController', '~> 1.9.8'
s.source_files = "AZQrCodeScanController/AZQrCodeScanController/*.{h,m}"
s.resources = "AZQrCodeScanController/AZQrCodeScanController/AZQrCode.bundle"
end
