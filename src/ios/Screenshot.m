//
// Screenshot.h
//
// Created by Simon Madine on 29/04/2010.
// Copyright 2010 The Angry Robot Zombie Factory.
// - Converted to Cordova 1.6.1 by Josemando Sobral.
// MIT licensed
//
// Modifications to support orientation change by @ffd8
//

#import <Cordova/CDV.h>
#import "Screenshot.h"
@implementation Screenshot

@synthesize webView;
- (UIImage *)getScreenshotWithTop:(NSNumber *)top Bottom:(NSNumber *)bottom Left:(NSNumber *)left Right:(NSNumber *)right {
	UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
	CGRect rect = [keyWindow bounds];
    
    UIView *view = [[UIView alloc] initWithFrame:rect];
    UIGraphicsBeginImageContext(view.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [keyWindow.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (top.integerValue == 0
        &&
        bottom.integerValue == 0
        &&
        left.integerValue == 0
        &&
        right.integerValue == 0) {
        return image;
    } else {
        if (top.integerValue < 0) {
            top = @(0);
        }
        if (bottom.integerValue < 0) {
            bottom = @(0);
        }
        if (left.integerValue < 0) {
            left = @(0);
        }
        if (right.integerValue < 0) {
            right = @(0);
        }
        NSInteger areaY = rect.origin.y + top.integerValue;
        NSInteger areaHeight = rect.size.height - top.integerValue - bottom.integerValue;
        if (areaHeight < 0) {
            areaHeight = rect.size.height;
        }
        NSInteger areaX = rect.origin.x + left.integerValue;
        NSInteger areaWidth = rect.size.width - left.integerValue - right.integerValue;
        if (areaWidth) {
            areaWidth = rect.size.width;
        }
        
        CGRect cropRect = CGRectMake(areaX, areaY, areaWidth, areaHeight);
        CGImageRef imagRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
        UIImage* cropImage = [UIImage imageWithCGImage: imagRef];
        CGImageRelease(imagRef);
        
        return cropImage;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (UIImage *)modefyImageWithImage:(UIImage *)image Width:(NSNumber *)width Height:(NSNumber *)height Mode:(NSString *)mode {

    if ([mode isEqualToString:@"fit"]) {//等比缩放
        return [self resizeImageWithImage:image Width:width Height:height];
    } else if ([mode isEqualToString:@"cover"]) {//截图部分        
        return [self coverImageWithImage:image Width:width Height:height];
    } else {//自定义尺寸缩放 "crop"
        
        UIImage *coverImage = [self coverImageWithImage:image Width:width Height:height];
        NSInteger widthDiff = round(coverImage.size.width - width.floatValue);
        NSInteger heightDiff = round(coverImage.size.height - height.floatValue);

        if (widthDiff > heightDiff) {
            //截取图像
            CGImageRef refImage = [coverImage CGImage];
            NSInteger refWidth = CGImageGetWidth(refImage);
            NSInteger refHeight = CGImageGetHeight(refImage);
            
            float scale = refHeight / coverImage.size.height;
            NSInteger targetWidth = round(width.floatValue * scale);
            NSInteger xPostion = (refWidth - targetWidth) / 2;
            CGRect cutRect = CGRectMake(xPostion, 0,targetWidth, refHeight);
            
            CGImageRef imageRef = CGImageCreateWithImageInRect(refImage, cutRect);
            UIImage *cropImage = [UIImage imageWithCGImage:imageRef];
            
            return cropImage;
        } else {
            //截取图像
            CGImageRef refImage = [coverImage CGImage];
            NSInteger refWidth = CGImageGetWidth(refImage);
            NSInteger refHeight = CGImageGetHeight(refImage);
            
            float scale = refWidth / coverImage.size.width;
            NSInteger targetHeight = round(height.floatValue * scale);
            NSInteger yPostion = (refHeight - targetHeight) / 2;
            CGRect cutRect = CGRectMake(0, yPostion, refWidth, targetHeight);
            
            CGImageRef imageRef = CGImageCreateWithImageInRect(refImage, cutRect);
            UIImage *cropImage = [UIImage imageWithCGImage:imageRef];
            
            return cropImage;
        }
    }
}

- (UIImage *)resizeImageWithImage:(UIImage *)image Width:(NSNumber *)width Height:(NSNumber *)height {
    
    float wScaleSize = width.floatValue/image.size.width;
    float hScaleSize = height.floatValue/image.size.height;
    float scaleSize = wScaleSize < hScaleSize ? wScaleSize: hScaleSize;
    
    NSInteger imageWidth = round(image.size.width * scaleSize);
    NSInteger imageHeight = round(image.size.height * scaleSize);

    UIGraphicsBeginImageContext(CGSizeMake(imageWidth, imageHeight));
    [image drawInRect:CGRectMake(0, 0, imageWidth, imageHeight)];
    UIImage *rescaleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return rescaleImage;
}

- (UIImage *)coverImageWithImage:(UIImage *)image Width:(NSNumber *)width Height:(NSNumber *)height {
    
    float wScaleSize = width.floatValue/image.size.width;
    float hScaleSize = height.floatValue/image.size.height;
    float scaleSize = wScaleSize > hScaleSize ? wScaleSize: hScaleSize;
    
    NSInteger imageWidth = round(image.size.width * scaleSize);
    NSInteger imageHeight = round(image.size.height * scaleSize);
    
    UIGraphicsBeginImageContext(CGSizeMake(imageWidth, imageHeight));
    [image drawInRect:CGRectMake(0, 0, imageWidth, imageHeight)];
    UIImage *rescaleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return rescaleImage;
}

- (void)saveScreenshot:(CDVInvokedUrlCommand*)command
{
    NSString *format = [command.arguments objectAtIndex:0];
    NSNumber *quality = [command.arguments objectAtIndex:1];
    NSString *jpgPath = [command.arguments objectAtIndex:2];
	NSString *filename = [command.arguments objectAtIndex:3];
    NSNumber *width = [command.arguments objectAtIndex:4];
    NSNumber *height = [command.arguments objectAtIndex:5];
    NSString *mode = [command.arguments objectAtIndex:6];
    
    NSNumber *cropTop = [command.arguments objectAtIndex:7];
    NSNumber *cropBottom = [command.arguments objectAtIndex:8];
    NSNumber *cropLeft = [command.arguments objectAtIndex:9];
    NSNumber *cropRight = [command.arguments objectAtIndex:10];

    NSString *path = @"";
    if (filename.length == 0) {
        filename = @"myscreenshot";
    }
    
    if ([format.lowercaseString isEqualToString:@"jpg"]) {
        path = [NSString stringWithFormat:@"%@.jpg",filename];
    } else {
        path = [NSString stringWithFormat:@"%@.png",filename];
    }
    self.imageFormat = format.lowercaseString;
    
    if (jpgPath.length == 0) {
        jpgPath = [NSTemporaryDirectory() stringByAppendingPathComponent:path];
    } else {
        jpgPath = [jpgPath stringByAppendingString:path];
         NSRange fileStr = [jpgPath rangeOfString:@"file://"];
        if (fileStr.length) {
            if (fileStr.location == 0) {
                jpgPath = [jpgPath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
            }
        }
    }

	UIImage *image = [self getScreenshotWithTop:cropTop Bottom:cropBottom Left:cropLeft Right:cropRight];
    
    if (width.floatValue > 0
        &&
        height.floatValue > 0
        &&
        mode.length > 0) {
        
        image = [self modefyImageWithImage:image Width:width Height:height Mode:mode];
    }
    NSData *imageData = [[NSData alloc] init];
    
    double imageQuality = [quality doubleValue]/100;
    if ([format.lowercaseString isEqualToString:@"jpg"]) {
        imageData = UIImageJPEGRepresentation(image,imageQuality);
    } else {
        imageData = UIImagePNGRepresentation(image);
    }
	[imageData writeToFile:jpgPath atomically:NO];

	CDVPluginResult* pluginResult = nil;
	NSDictionary *jsonObj = [ [NSDictionary alloc]
		initWithObjectsAndKeys :
		jpgPath, @"filePath",
		@"true", @"success",
		nil
	];

	pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:jsonObj];
	NSString* callbackId = command.callbackId;
	[self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void) getScreenshotAsURI:(CDVInvokedUrlCommand*)command
{
	NSNumber *quality = command.arguments[0];
	UIImage *image = [self getScreenshotWithTop:0 Bottom:0 Left:0 Right:0];
    NSData *imageData = [[NSData alloc] init];
    
    double imageQuality = [quality doubleValue]/100;
    if ([self.imageFormat.lowercaseString isEqualToString:@"jpg"]) {
        imageData = UIImageJPEGRepresentation(image,imageQuality);
    } else {
        imageData = UIImagePNGRepresentation(image);
    }	NSString *base64Encoded = [imageData base64EncodedStringWithOptions:0];
	NSDictionary *jsonObj = @{
	    @"URI" : [NSString stringWithFormat:@"data:image/jpeg;base64,%@", base64Encoded]
	};
	CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:jsonObj];
	[self.commandDelegate sendPluginResult:pluginResult callbackId:[command callbackId]];
}
@end
