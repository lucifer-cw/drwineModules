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

RCT_EXPORT_MODULE(PingPayModule)

RCT_EXPORT_METHOD(normalPayAction:(NSDictionary*)charge appUrlScheme:(NSString*)schemestr){
    
    //第一步，创建URL
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://218.244.151.190/demo/charge"]];
    //第二步，通过URL创建网络请求
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]init];
    NSDictionary* dict = @{
                           @"channel" : @"alipay",
                           @"amount"  : @"1"
                           };
    NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    NSString *bodyData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [request setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String] length:strlen([bodyData UTF8String])]];
    [request setHTTPMethod:@"POST"];
    [request setURL:url]; //设置请求的地址
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    //    NSData * backData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSString* rccharge = [[NSString alloc] initWithData:received encoding:NSUTF8StringEncoding];
    
    NSString *jsonString = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    
    if (!jsonData) {
        return ;
    }
    
    NSDictionary *datadic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&err];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[datadic objectForKey:@"data"]];
    dic = [dic objectForKey:@"pingPPcharge"];
    [dic setValue:@"wx" forKey:@"channel"];
    
    [Pingpp createPayment:rccharge appURLScheme:@"wx85405b917ac80b5d" withCompletion:^(NSString *result, PingppError *error) {
        if (error == nil) {
            NSLog(@"PingppError is nil");
        } else {
            NSLog(@"PingppError: code=%lu msg=%@", (unsigned  long)error.code, [error getMsg]);
        }
    }];
}

+(BOOL)handleOpenURL:(NSURL *)url delegate:(id)delegate{
    return [Pingpp handleOpenURL:url withCompletion:nil];
}

@end
