//
//  UIImageAdditions.h
//  Sample
//
//  Created by Kirby Turner on 2/7/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface UIImage (KTCategory)

- (UIImage *)transformWidth:(CGFloat)width
                     height:(CGFloat)height;
- (UIImage *)scaleAspectToWidth:(CGFloat)width
                         height:(CGFloat)height;

- (UIImage *)minsizetoFillWith:(CGFloat)width height:(CGFloat)height;           //按照小边填充满，等比放大
- (UIImage *)minscaleAspectToWidth:(CGFloat)width height:(CGFloat)height;       //按照原比例缩放，居中截除多余部分(过滤小图)；

- (UIImage *)allminscaleAspectToWidth:(CGFloat)width height:(CGFloat)height;       //按照原比例缩放，居中截除多余部分（小图执行放大操作）；

- (UIImage *)fixRotation;
- (UIImage *)imageScaleAspectToMaxSize:(CGFloat)newSize;
- (UIImage *)imageScaleAndCropToMaxSize:(CGSize)newSize;

@end
