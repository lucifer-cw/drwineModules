//
//  PingPay.h
//  nativeModules
//
//  Created by 398403854@qq.com陈伟 on 2017/2/20.
//  Copyright © 2017年 drwine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface PingPay : NSObject <RCTBridgeModule>

+ (BOOL)handleOpenURL:(NSURL*)url delegate:(id)delegate;

@end
