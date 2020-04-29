#import "ImageNativeResizerPlugin.h"
#import "FLTImagePickerImageUtil.h"
#import "FLTImagePickerPhotoAssetUtil.h"
#import <Photos/Photos.h>

@implementation ImageNativeResizerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"image_native_resizer"
            binaryMessenger:[registrar messenger]];
  ImageNativeResizerPlugin* instance = [[ImageNativeResizerPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"resize" isEqualToString:call.method]) {
    NSString *imagePath = call.arguments[@"imagePath"];
    NSNumber *maxWidth = call.arguments[@"maxWidth"];
    NSNumber *maxHeight = call.arguments[@"maxHeight"];
    NSNumber *imageQuality = call.arguments[@"quality"];

    if (![imageQuality isKindOfClass:[NSNumber class]]) {
      imageQuality = @1;
    } else if (imageQuality.intValue < 0 || imageQuality.intValue > 100) {
      imageQuality = [NSNumber numberWithInt:1];
    } else {
      imageQuality = @([imageQuality floatValue] / 100);
    }

    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    UIImage *image = [UIImage imageWithData:imageData];
    image = [FLTImagePickerImageUtil scaledImage:image maxWidth:maxWidth maxHeight:maxHeight];
    
    NSString *resizedPath = [FLTImagePickerPhotoAssetUtil saveImageWithOriginalImageData:imageData
                                                          image:image
                                                       maxWidth:maxWidth
                                                      maxHeight:maxHeight
                                                   imageQuality:imageQuality];
    result(resizedPath);
                            
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
