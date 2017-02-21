//
//  UIImageAdditions.m
//  Sample
//
//  Created by Kirby Turner on 2/7/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import "UIImage+KTCategory.h"


@implementation UIImage (KTCategory)

- (UIImage *)transformWidth:(CGFloat)width
                     height:(CGFloat)height
{
    CGFloat destW = width;
    CGFloat destH = height;
    CGFloat sourceW = width;
    CGFloat sourceH = height;
    
    CGImageRef imageRef = self.CGImage;
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                destW,
                                                destH,
                                                CGImageGetBitsPerComponent(imageRef),
                                                4 * destW,
                                                CGImageGetColorSpace(imageRef),
                                                (kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst));
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, sourceW, sourceH), imageRef);
    
    
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage *result = [UIImage imageWithCGImage:ref];
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    return result;
}

- (UIImage *)scaleAspectToWidth:(CGFloat)width
                         height:(CGFloat)height
{
    CGFloat h = self.size.height;
    CGFloat w = self.size.width;
    if (h < height && w < width) {
        return self;
    }
    CGFloat ratio = (width / w) < (height / h)? (width / w): (height / h);
    CGSize newSize = CGSizeMake((NSInteger)(ratio * w), (NSInteger)(ratio * h));
    UIGraphicsBeginImageContext(newSize);
    CGRect newRect = CGRectMake(0, 0, newSize.width, newSize.height);
    [self drawInRect:newRect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)minsizetoFillWith:(CGFloat)width height:(CGFloat)height{
    CGFloat h = self.size.height;
    CGFloat w = self.size.width;
    if (h < height && w < width) {
        return self;
    }
    CGFloat ratio = (width / w) >(height / h)? (width / w): (height / h);
    CGSize newSize = CGSizeMake((NSInteger)(ratio * w), (NSInteger)(ratio * h));
    UIGraphicsBeginImageContext(newSize);
    CGRect newRect = CGRectMake(0, 0, newSize.width, newSize.height);
    [self drawInRect:newRect];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    return scaledImage;
}



- (UIImage *)minscaleAspectToWidth:(CGFloat)width height:(CGFloat)height{
    CGFloat h = self.size.height;
    CGFloat w = self.size.width;
    if (h < height && w < width) {
        return self;
    }
//    CGFloat ratio = (width / w) >(height / h)? (width / w): (height / h);
//    CGSize newSize = CGSizeMake((NSInteger)(ratio * w), (NSInteger)(ratio * h));
//    UIGraphicsBeginImageContext(newSize);
//    CGRect newRect = CGRectMake(0, 0, newSize.width, newSize.height);
//    [self drawInRect:newRect];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    
//    image = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([image CGImage], CGRectMake(0, 0, width, height))];
//    UIGraphicsEndImageContext();
    
    
    UIImage *newImage;
    CGSize newRect;
    
    float verticalRadio =self.size.height*1.0/width;// h
    float horizontalRadio = self.size.width*1.0/height;//w
    if (verticalRadio>=horizontalRadio) {

        UIGraphicsBeginImageContext(CGSizeMake(self.size.width/horizontalRadio,self.size.height/horizontalRadio));
        [self drawInRect:CGRectMake(0, 0,self.size.width/horizontalRadio,self.size.height/horizontalRadio)];
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        CGImageRef sourceImageRef = [scaledImage CGImage];
        newRect = scaledImage.size;
        scaledImage = nil;
        
        CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, CGRectMake(0, (newRect.height- height)/2, width, height));
        newImage = [UIImage imageWithCGImage:newImageRef];
        sourceImageRef = nil;

    }else{
        UIGraphicsBeginImageContext(CGSizeMake(self.size.width/verticalRadio,self.size.height/verticalRadio));
        [self drawInRect:CGRectMake(0, 0,self.size.width/verticalRadio,self.size.height/verticalRadio)];
        
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        CGImageRef sourceImageRef = [scaledImage CGImage];
        newRect = scaledImage.size;
        scaledImage = nil;
        
        CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, CGRectMake((newRect.width - width)/2, 0, width, height));
        newImage = [UIImage imageWithCGImage:newImageRef];
        sourceImageRef = nil;
    }
    
    return newImage;
}

-(UIImage *)allminscaleAspectToWidth:(CGFloat)width height:(CGFloat)height{

    UIImage *newImage;
    CGSize newRect;
    
    float verticalRadio =self.size.height*1.0/width;// h
    float horizontalRadio = self.size.width*1.0/height;//w
    if (verticalRadio>=horizontalRadio) {
        
        UIGraphicsBeginImageContext(CGSizeMake(self.size.width/horizontalRadio,self.size.height/horizontalRadio));
        [self drawInRect:CGRectMake(0, 0,self.size.width/horizontalRadio,self.size.height/horizontalRadio)];
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        CGImageRef sourceImageRef = [scaledImage CGImage];
        newRect = scaledImage.size;
        scaledImage = nil;
        
        CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, CGRectMake(0, (newRect.height- height)/2, width, height));
        newImage = [UIImage imageWithCGImage:newImageRef];
        sourceImageRef = nil;
        
    }else{
        UIGraphicsBeginImageContext(CGSizeMake(self.size.width/verticalRadio,self.size.height/verticalRadio));
        [self drawInRect:CGRectMake(0, 0,self.size.width/verticalRadio,self.size.height/verticalRadio)];
        
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        CGImageRef sourceImageRef = [scaledImage CGImage];
        newRect = scaledImage.size;
        scaledImage = nil;
        
        CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, CGRectMake((newRect.width - width)/2, 0, width, height));
        newImage = [UIImage imageWithCGImage:newImageRef];
        sourceImageRef = nil;
    }
    
    return newImage;
}


- (UIImage *)imageScaleAspectToMaxSize:(CGFloat)newSize {
   CGSize size = [self size];
   CGFloat ratio;
   if (size.width > size.height) {
      ratio = newSize / size.width;
   } else {
      ratio = newSize / size.height;
   }
   
   CGRect rect = CGRectMake(0.0, 0.0, round(ratio * size.width), round(ratio * size.height));
   UIGraphicsBeginImageContext(rect.size);
   [self drawInRect:rect];
   UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
   return scaledImage;
}

- (UIImage *)fixRotation
{
    if (self.imageOrientation == UIImageOrientationUp)
        return self;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL,
                                             self.size.width,
                                             self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage),
                                             0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.height, self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.width, self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


- (UIImage *)imageScaleAndCropToMaxSize:(CGSize)newSize {
   CGFloat largestSize = (newSize.width > newSize.height) ? newSize.width : newSize.height;
   CGSize imageSize = [self size];
   
   // Scale the image while mainting the aspect and making sure the 
   // the scaled image is not smaller then the given new size. In
   // other words we calculate the aspect ratio using the largest
   // dimension from the new size and the small dimension from the
   // actual size.
   CGFloat ratio;
   if (imageSize.width > imageSize.height) {
      ratio = largestSize / imageSize.height;
   } else {
      ratio = largestSize / imageSize.width;
   }
   
   CGRect rect = CGRectMake(0.0, 0.0, ratio * imageSize.width, ratio * imageSize.height);
   UIGraphicsBeginImageContext(rect.size);
   [self drawInRect:rect];
   UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
   
   // Crop the image to the requested new size maintaining
   // the inner most parts of the image.
   CGFloat offsetX = 0;
   CGFloat offsetY = 0;
   imageSize = [scaledImage size];
   if (imageSize.width < imageSize.height) {
      offsetY = (imageSize.height / 2) - (imageSize.width / 2);
   } else {
      offsetX = (imageSize.width / 2) - (imageSize.height / 2);
   }
   
   CGRect cropRect = CGRectMake(offsetX, offsetY,
                                imageSize.width - (offsetX * 2),
                                imageSize.height - (offsetY * 2));
   
   CGImageRef croppedImageRef = CGImageCreateWithImageInRect([scaledImage CGImage], cropRect);
   UIImage *newImage = [UIImage imageWithCGImage:croppedImageRef];
   CGImageRelease(croppedImageRef);
   
   return newImage;
}


@end
