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

![这里写图片描述](http://img.blog.csdn.net/20170611122801271?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvUG9pbnRlZQ==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

### 项目地址

[github地址](https://github.com/CoderAzreal/AZQrCodeScanController)
