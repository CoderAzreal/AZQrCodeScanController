# AZQrCodeScanController
### 介绍
	AZQrCodeScanController 是对iOS原生框架AVFoundation, 一句话即可调用iOS原生扫码。

### installation

```
	// 全部导入(包含OC和swift)
	pod 'AZQrCodeScanController'
	// 只导入swift
	pod 'AZQrCodeScanController/swift'
	// 只导入OC
	pod 'AZQrCodeScanController/oc'
```

### 初始化方法 (OC)
``` Objection-C
	AZQrCodeScanController *c = [[AZQrCodeScanController alloc] initWithScanComplete:^*(NSString *result) {
		NSLog(@"%@", result);
	}];
	[self presentViewController:c animated:true completion: nil];
```
### 初始化方法(swift)
``` swift
	let c = AZQrCodeScanController { (result) in
	    print(result)        
    	}
    	present(c!, animated: true, completion: nil)
```

### 效果图

![示例图](http://upload-images.jianshu.io/upload_images/6499192-cf231dd9650d312d.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 项目地址

[github地址](https://github.com/CoderAzreal/AZQrCodeScanController)
