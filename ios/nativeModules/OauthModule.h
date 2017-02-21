//
//  OauthModule.h
//  nativeModules
//
//  Created by 398403854@qq.com陈伟 on 2017/2/20.
//  Copyright © 2017年 drwine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <UIKit/UIKit.h>
#import "WXApi.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentApiInterface.h>
#import "WeiboSDK.h"


@interface OauthModule : NSObject<RCTBridgeModule,WXApiDelegate,TencentSessionDelegate,WBHttpRequestDelegate>

@property(nonatomic,strong) RCTResponseSenderBlock sinawbcallback;
@property(nonatomic,strong) RCTResponseSenderBlock wxcallback;
@property(nonatomic,strong) RCTResponseSenderBlock tencentcallback;


+ (OauthModule*)sharedInstance;

+ (TencentOAuth*)getTencentOAuthInstance;

+ (TencentOAuth *)registerQQWithAppkey:(NSString *)appkey;

+ (void)registerSinaWbWithAppkey:(NSString *)appkey;

+ (void)registerWithAppkey:(NSString *)appkey launchOptions:(NSDictionary *)launchOptions;

+ (BOOL)handleOpenURL:(NSURL*)url delegate:(id)delegate;

@end
