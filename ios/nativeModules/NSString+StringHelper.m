//
//  NSString+StringHelper.m
//  fwqdatajsonDemo
//
//  Created by wuxian on 13-11-23.
//  Copyright (c) 2013年 wuxian. All rights reserved.
//

#import "NSString+StringHelper.h"

@implementation NSString (StringHelper)

- (NSString*)encodeAsURIComponent
{
    if (!self.length) return @"";
    
    static const char* characters = "0123456789ABCDEF";
    
    const char* src = [self UTF8String];
    if (!src) return @"";
    
    NSUInteger len = [self lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    char buf[len*3];
    char* dest = buf;
    
    for (NSInteger i=len-1; i>=0; --i) {
        unsigned char c = *src++;
        if (('a' <= c && c <= 'z')
            || ('A' <= c && c <= 'Z')
            || ('0' <= c && c <= '9')
            || (c == '_')
            || (c == '-')
            || (c == '.')
            || (c == '~')) {
            *dest++ = c;
        }
        else {
            *dest++ = '%';
            *dest++ = characters[c / 16];
            *dest++ = characters[c % 16];
        }
    }
	
    return [[NSString alloc] initWithBytes:buf length:dest - buf encoding:NSASCIIStringEncoding];
}

@end
