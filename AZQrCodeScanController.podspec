Pod::Spec.new do |s|
s.name = "AZQrCodeScanController"
s.version = "1.0.1"
s.ios.deployment_target = '8.0'
s.summary = "iOS原生扫码控制器"
s.homepage = "https://github.com/CoderAzreal/AZQrCodeScanController"
s.license = { :type => "MIT", :file => "LICENSE" }
s.author = {"AZReal" => "tianfengyu@foxmail.com" }
s.source = { :git => "https://github.com/CoderAzreal/AZQrCodeScanController.git", :tag => s.version }
s.source_files = "AZQrCodeScanController/AZQrCodeScanController/*.{h,m}"
s.resources = "AZQrCodeScanController/AZQrCodeScanController/AZQrCode.bundle"
s.requires_arc = true
s.subspec 'swift' do |t|
	t.source_files = 'AZQrCodeScanController-Swift/*.{swift}'
	t.resources = 'AZQrCodeScanController-Swift/AZQrCode.bundle'
end
end
