cordova-screenshot
==================

[![NPM version](http://img.shields.io/npm/v/com.codeplay.cordova.screenshot.svg?style=flat)](https://www.npmjs.com/package/com.codeplay.cordova.screenshot)


The Screenshot plugin allows your cordova application to take screenshots in JPG or PNG, resize or crop them and save them into any folders.

##how to install

install it via cordova cli

```
cordova plugin add https://github.com/jammind/cordova-screenshot.git
```

notice:
It supports only iOS now. I plan to support Android in the future.
It is based on https://github.com/gitawego/cordova-screenshot. The original plugin supports iOS / OS X / Android.
##usage


```js
navigator.screenshot.save(callback, options);

function callback(error,result){
	if(error){
		console.error(error);
	}else{
		console.log('ok',result.filePath);
	}
}

take screenshot with jpg and custom quality
{
	format: ‘jpg’, // Image format ‘jpg’(default) ‘png'
	quality: 50, // JPEG quality [0-100] 50 by default
	path: cordova.file.documentsDirectory, // 保存路径，缺省为temp文件夹
	filename: ‘myscreenshot’, // 指定文件名，后缀根据格式自动追加，缺省则自动生成文件名
	// The following 3 attributes require each other to work
	width: 240, // Target area width in pixel
	height: 240, // 目标高度
	mode: ‘crop’ // ‘fit’ ‘cover’ ‘crop’缩放裁切模式，定义见下图
}
```

License
=========
this repo uses the MIT license
