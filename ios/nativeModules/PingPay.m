//
//  PingPay.m
//  nativeModules
//
//  Created by 398403854@qq.com陈伟 on 2017/2/20.
//  Copyright © 2017年 drwine. All rights reserved.
//

#import "PingPay.h"
#import "Pingpp.h"

@implementation PingPay

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE(DRPingPP)

RCT_EXPORT_METHOD(createPayment:(id)charge appUrlScheme:(NSString*)schemestr callBack:(RCTResponseSenderBlock)callback){
        
    [Pingpp createPayment:charge appURLScheme:schemestr withCompletion:^(NSString *result, PingppError *error) {
        if ([result isEqualToString:@"success"]) {
            // 支付成功
            if(callback){
                callback(@[@"ok"]);
            }
        } else {
            // 支付失败或取消
            if(callback){
                callback(@[[NSString stringWithFormat:@"%i",error.code],[error getMsg]]);
            }
        }
    }];
}

+(BOOL)handleOpenURL:(NSURL *)url delegate:(id)delegate{
    return [Pingpp handleOpenURL:url withCompletion:nil];
}

@end
