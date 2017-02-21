//
//  OauthModule.m
//  nativeModules
//
//  Created by 398403854@qq.com陈伟 on 2017/2/20.
//  Copyright © 2017年 drwine. All rights reserved.
//

#import "OauthModule.h"
#import "NSString+StringHelper.h"
#import "UIImage+KTCategory.h"

#define kRedirectURI    @"https://api.weibo.com/oauth2/default.html"

static OauthModule *_instance = nil;
static TencentOAuth *_tencentinstance = nil;


@implementation OauthModule

@synthesize bridge = _bridge;

@synthesize wxcallback;

RCT_EXPORT_MODULE(ThirdOAuthModule)

RCT_EXPORT_METHOD(getWXAppIsInstall:(RCTResponseSenderBlock)callback){
    bool isinstall = [WXApi isWXAppInstalled];
    NSString *isInstall = [NSString stringWithFormat:@"%@",isinstall?@"YES":@"NO"];
    callback(@[isInstall]);
}


RCT_EXPORT_METHOD(getQQAppIsInstall:(RCTResponseSenderBlock)callback){
    bool isinstall = [TencentOAuth iphoneQQInstalled];
    NSString *isInstall = [NSString stringWithFormat:@"%@",isinstall?@"YES":@"NO"];
    callback(@[isInstall]);
}

RCT_EXPORT_METHOD(getSinaWbAppIsInstall:(RCTResponseSenderBlock)callback){
    bool isinstall = [WeiboSDK isWeiboAppInstalled];
    NSString *isInstall = [NSString stringWithFormat:@"%@",isinstall?@"YES":@"NO"];
    callback(@[isInstall]);
}


#pragma mark OAuth Method


RCT_EXPORT_METHOD(goToWeiXinOAuth:(RCTResponseSenderBlock)callback) {
    SendAuthReq* req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo"; // @"post_timeline,sns"
    req.state = @"123";
    [WXApi sendReq:req];
    
    [OauthModule sharedInstance].wxcallback = [callback copy];
    
}

RCT_EXPORT_METHOD(goToQQOAuth:(RCTResponseSenderBlock)callback){
    [OauthModule sharedInstance].tencentcallback = [callback copy];
    // 主线程执行：
    dispatch_async(dispatch_get_main_queue(), ^{
        // something
        NSArray* _permissions =  [NSArray arrayWithObjects:@"get_user_info", @"get_simple_userinfo", @"add_t", nil];
        [[self getTencentOAuthInstance] authorize:_permissions inSafari:NO];
    });
}

RCT_EXPORT_METHOD(goToSinaWBOAuth:(RCTResponseSenderBlock)callback){
    [OauthModule sharedInstance].sinawbcallback = [callback copy];
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = kRedirectURI;
    request.scope = @"all";
    [WeiboSDK sendRequest:request];
}

#pragma mark SHARE Method
#pragma mark WX-Share

RCT_EXPORT_METHOD(sendWxContentWithTitle:(NSString*)title Content:(NSString*)appMessage WithUrl:(NSString*)appUrl WithScene:(int)scene ImgUrl:(NSString*)imgurl){
    // 发送内容给微信
    WXMediaMessage *message = [WXMediaMessage message];
    if (WXSceneTimeline == scene)
    {
        message.title = appMessage;
    }
    else
    {
        message.title = title;
    }
    message.description = appMessage;
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self changeImgUrlStringWH:imgurl]]]];
    NSData *newdata = UIImageJPEGRepresentation(image, 0.8);
    [message setThumbData:newdata];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = appUrl;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    
    [WXApi sendReq:req];
}

RCT_EXPORT_METHOD(sendWxContentWithImg:(UIImage *)image WithScene:(int)scene){
    // 微信 图片分享
    WXMediaMessage *message = [WXMediaMessage message];
    
    NSData *newdata = UIImageJPEGRepresentation([image scaleAspectToWidth:240.f height:240.f/image.size.width*image.size.height], 0.2);//
    [message setThumbData:newdata];
    
    WXImageObject *imgobject = [WXImageObject object];
    imgobject.imageData = UIImageJPEGRepresentation(image,1.0);
    message.mediaObject = imgobject;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    [WXApi sendReq:req];
}

#pragma mark QQ-Share

RCT_EXPORT_METHOD(sendQQContentWithTitle:(NSString*)title Content:(NSString*)appMessage WithUrl:(NSString*)appUrl WithScene:(int)scene ImgUrl:(NSString*)imgurl){
    // 发送内容给QQ&&QQ空间
    QQApiNewsObject *newsObj = [QQApiNewsObject
                                objectWithURL :[NSURL URLWithString:[appUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                                title:title
                                description:appMessage
                                previewImageURL:[NSURL URLWithString:imgurl]];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
    if (scene==0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //将内容分享到qq
            QQApiSendResultCode sent = [QQApiInterface sendReq:req];
        });
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            //将内容分享到qzone
            QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
        });
    }
}


#pragma mark Sina-Share

RCT_EXPORT_METHOD(sendSinaWbContentWithTitle:(NSString*)title Content:(NSString*)appMessage WithUrl:(NSString*)appUrl ImgUrl:(NSString*)imgurl){
    // 发送内容给微信
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = kRedirectURI;
    authRequest.scope = @"all";
    
    WBImageObject *imageMessage = [WBImageObject object];
    imageMessage.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgurl]];
    
    WBMessageObject *message = [WBMessageObject message];
    message.text = appMessage;
    message.imageObject = imageMessage;
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:nil];
    [WeiboSDK sendRequest:request];
}



#pragma mark - sb
#pragma WBHttpRequestDelegate

- (void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result
{
    NSString *title = nil;
    UIAlertView *alert = nil;
    
    title = NSLocalizedString(@"收到网络回调", nil);
    alert = [[UIAlertView alloc] initWithTitle:title
                                       message:[NSString stringWithFormat:@"%@",result]
                                      delegate:nil
                             cancelButtonTitle:NSLocalizedString(@"确定", nil)
                             otherButtonTitles:nil];
    [alert show];
}

- (void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error;
{
    NSString *title = nil;
    UIAlertView *alert = nil;
    
    title = NSLocalizedString(@"请求异常", nil);
    alert = [[UIAlertView alloc] initWithTitle:title
                                       message:[NSString stringWithFormat:@"%@",error]
                                      delegate:nil
                             cancelButtonTitle:NSLocalizedString(@"确定", nil)
                             otherButtonTitles:nil];
    [alert show];
}

#pragma mark sina WeiboResponse

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
        NSString *title = NSLocalizedString(@"发送结果", nil);
        NSString *message = [NSString stringWithFormat:@"%@: %d\n%@: %@\n%@: %@", NSLocalizedString(@"响应状态", nil), (int)response.statusCode, NSLocalizedString(@"响应UserInfo数据", nil), response.userInfo, NSLocalizedString(@"原请求UserInfo数据", nil),response.requestUserInfo];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                              otherButtonTitles:nil];
        WBSendMessageToWeiboResponse* sendMessageToWeiboResponse = (WBSendMessageToWeiboResponse*)response;
        NSString* accessToken = [sendMessageToWeiboResponse.authResponse accessToken];
        //        if (accessToken)
        //        {
        //            self.wbtoken = accessToken;
        //        }
        //        NSString* userID = [sendMessageToWeiboResponse.authResponse userID];
        //        if (userID) {
        //            self.wbCurrentUserID = userID;
        //        }
        [alert show];
    }
    else if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        if (response.statusCode == WeiboSDKResponseStatusCodeSuccess) {
            NSMutableDictionary *paradic = [[NSMutableDictionary alloc]initWithCapacity:1];
            [paradic setValue:[(WBAuthorizeResponse *)response accessToken] forKey:@"access_token"];
            [paradic setValue:[(WBAuthorizeResponse *)response userID] forKey:@"uid"];
            [self getsinawbUserInfoWith:paradic];
        }else{
            NSLog(@"falisssdfsdf---jhkjh");
        }
        
    }
    else if ([response isKindOfClass:WBPaymentResponse.class])
    {
        NSString *title = NSLocalizedString(@"支付结果", nil);
        NSString *message = [NSString stringWithFormat:@"%@: %d\nresponse.payStatusCode: %@\nresponse.payStatusMessage: %@\n%@: %@\n%@: %@", NSLocalizedString(@"响应状态", nil), (int)response.statusCode,[(WBPaymentResponse *)response payStatusCode], [(WBPaymentResponse *)response payStatusMessage], NSLocalizedString(@"响应UserInfo数据", nil),response.userInfo, NSLocalizedString(@"原请求UserInfo数据", nil), response.requestUserInfo];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
    else if([response isKindOfClass:WBSDKAppRecommendResponse.class])
    {
        NSString *title = NSLocalizedString(@"邀请结果", nil);
        NSString *message = [NSString stringWithFormat:@"accesstoken:\n%@\nresponse.StatusCode: %d\n响应UserInfo数据:%@\n原请求UserInfo数据:%@",[(WBSDKAppRecommendResponse *)response accessToken],(int)response.statusCode,response.userInfo,response.requestUserInfo];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }else if([response isKindOfClass:WBShareMessageToContactResponse.class])
    {
        NSString *title = NSLocalizedString(@"发送结果", nil);
        NSString *message = [NSString stringWithFormat:@"%@: %d\n%@: %@\n%@: %@", NSLocalizedString(@"响应状态", nil), (int)response.statusCode, NSLocalizedString(@"响应UserInfo数据", nil), response.userInfo, NSLocalizedString(@"原请求UserInfo数据", nil),response.requestUserInfo];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                              otherButtonTitles:nil];
        WBShareMessageToContactResponse* shareMessageToContactResponse = (WBShareMessageToContactResponse*)response;
        NSString* accessToken = [shareMessageToContactResponse.authResponse accessToken];
        //        if (accessToken)
        //        {
        //            self.wbtoken = accessToken;
        //        }
        //        NSString* userID = [shareMessageToContactResponse.authResponse userID];
        //        if (userID) {
        //            self.wbCurrentUserID = userID;
        //        }
        [alert show];
    }
}

#pragma mark TencentSessionDelegate
- (void)tencentDidLogin {
    // 登录成功
    
    TencentOAuth *_tencentOAuth = [self getTencentOAuthInstance];
    
    if (_tencentOAuth.accessToken&& 0 != [_tencentOAuth.accessToken length])
    {
        if(![_tencentOAuth getUserInfo]){
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"api调用失败" message:@"可能授权已过期，请重新获取" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    else
    {
        NSLog(@"登录不成功 没有获取accesstoken");
    }
}

-(void)tencentDidNotLogin:(BOOL)cancelled{
    if (cancelled)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"失败" message:@"用户取消登录" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"调用失败" message:@"登录失败" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)tencentDidNotNetWork
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"调用失败" message:@"无网络连接，请设置网络" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

/*
 qq openId 用户授权唯一ID
 */

-(void)getUserInfoResponse:(APIResponse *)response{
    TencentOAuth *_tencentOAuth = [self getTencentOAuthInstance];
    NSMutableString *mutableUid = [[NSMutableString alloc] init];
    [mutableUid appendString:@"qq_"];
    [mutableUid appendString:_tencentOAuth.openId];
    NSString * nickName = [response.jsonResponse objectForKey:@"nickname"];
    NSString * headImgUrl = [[response jsonResponse] objectForKey:@"figureurl_qq_2"];
    NSMutableDictionary *datadic = [[NSMutableDictionary alloc]initWithCapacity:1];
    [datadic setValue:_tencentOAuth.accessToken forKey:@"accessToken"];
    [datadic setValue:mutableUid forKey:@"qqopenid"];
    [datadic setValue:_tencentOAuth.openId forKey:@"openid"];
    [datadic setValue:nickName forKey:@"nickname"];
    [datadic setValue:headImgUrl forKey:@"avater_url"];
    if ([[response.jsonResponse objectForKey:@"gender"]isEqualToString:@"男"]) {
        [datadic setValue:@"1" forKey:@"gender"];
    }else if([[response.jsonResponse objectForKey:@"gender"]isEqualToString:@"女"]){
        [datadic setValue:@"0" forKey:@"gender"];
    }
    [OauthModule sharedInstance].tencentcallback(@[datadic]);
}


- (TencentOAuth*)getTencentOAuthInstance{
    
    if (_tencentinstance == nil) {
        _tencentinstance = [[TencentOAuth alloc] initWithAppId:@"100970497"
                                                   andDelegate:[OauthModule sharedInstance]];
    }
    return _tencentinstance;
}


#pragma mark WXonResp
-(void)onResp:(BaseResp *)resp{
    
    if ([resp isKindOfClass:[SendAuthResp class]] && resp.errCode == 0) {
        if ([self respondsToSelector:@selector(managerDidRecvAuthResponse:)]) {
            [self managerDidRecvAuthResponse:resp];
        }
    }
}

#pragma mark func

-(NSString*) changeImgUrlStringWH:(NSString *)oristring{
    NSString *outputstr = [NSString stringWithFormat:@""];
    
    NSString *str1 = [NSString stringWithFormat:@"?"];
    NSRange range1 = [oristring rangeOfString:str1];
    if (range1.location != NSNotFound && range1.length != 0) {
        NSString *str = [NSString stringWithFormat:@"imageView2/1/"];
        NSRange range = [oristring rangeOfString:str];
        if (range.location != NSNotFound && range.length != 0) {
            outputstr = [oristring substringToIndex:range.location];
        }else{
            outputstr = [NSString stringWithString:oristring];
        }
        outputstr = [outputstr stringByAppendingString:@"imageView2/1/w/160/h/160"];//&w=160&h=160
    }else{
        outputstr = [NSString stringWithFormat:@"%@%@",oristring,@"?imageView2/1/w/160/h/160"];//?&w=160&h=160
    }
    return outputstr;
}

-(void)getsinawbUserInfoWith:(NSDictionary*)dic{
    NSDictionary *sinaUserdic = [self requestApiWith:@"https://api.weibo.com/2/users/show.json?" param:dic];
    [OauthModule sharedInstance].sinawbcallback(@[sinaUserdic]);
}

-(void)managerDidRecvAuthResponse:(SendAuthResp*)authResp{
    //    NSString *strMsg = [NSString stringWithFormat:@"code:%@,state:%@,errcode:%d", authResp.code, authResp.state, authResp.errCode];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    [dic setValue:@"wx85405b917ac80b5d" forKey:@"appid"];
    [dic setValue:@"b1e6ba2c6775f2ee93749a93a7a22d51" forKey:@"secret"];
    [dic setValue:authResp.code forKey:@"code"];
    [dic setValue:@"authorization_code" forKey:@"grant_type"];
    
    NSDictionary *accessdic = [self requestApiWith:@"https://api.weixin.qq.com/sns/oauth2/access_token?" param:dic];
    [dic removeAllObjects];
    [dic setValue:[accessdic objectForKey:@"access_token"] forKey:@"access_token"];
    [dic setValue:[accessdic objectForKey:@"openid"] forKey:@"openid"];
    NSDictionary *userdic = [self requestApiWith:@"https://api.weixin.qq.com/sns/userinfo?" param:dic];
    if (userdic.count>0) {
        [OauthModule sharedInstance].wxcallback(@[userdic]);
    }
    
}



#pragma mark API Req

- (NSString*)buildParameters:(NSDictionary*)params
{
    NSMutableString* s = [NSMutableString string];
    
    for (NSString* key in params) {
        NSString* value = [[params objectForKey:key] encodeAsURIComponent];
        [s appendFormat:@"%@=%@&", key, value];
    }
    if (s.length > 0) [s deleteCharactersInRange:NSMakeRange(s.length-1, 1)];
    return s;
}


-(NSDictionary *)requestApiWith:(NSString*)rooturl param:(NSDictionary*)dic{
    NSString *fullUrl = dic.count?[self buildParameters:dic]:@"";
    //第一步，创建URL
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",rooturl,fullUrl]];
    //第二步，通过URL创建网络请求
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSString *jsonString = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    
    if (!jsonData) {
        return nil;
    }
    
    NSDictionary *datadic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&err];
    return datadic;
}


#pragma mark class me

+ (instancetype)sharedInstance {
    
    if(_instance == nil) {
        _instance = [[self alloc] init];
    }
    return _instance;
}

+(TencentOAuth *)registerQQWithAppkey:(NSString *)appkey{
    if (_tencentinstance == nil) {
        _tencentinstance = [[TencentOAuth alloc] initWithAppId:appkey
                                                   andDelegate:[OauthModule sharedInstance]];
    }
    return _tencentinstance;
}

+(void)registerSinaWbWithAppkey:(NSString *)appkey{
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:appkey];
}

+(void)registerWithAppkey:(NSString *)appkey launchOptions:(NSDictionary *)launchOptions{
    [WXApi registerApp:appkey];
}

+(BOOL)handleOpenURL:(NSURL *)url delegate:(id)delegate{
    if ([[url scheme] compare:@"tencent100970497"] == NSOrderedSame) {
        return [TencentOAuth HandleOpenURL:url];
    }else if ([[url scheme] compare:@"wx85405b917ac80b5d"] == NSOrderedSame) {
        return [WXApi handleOpenURL:url delegate:delegate];
    }else if ([[url scheme] compare:@"wb1716765740"] == NSOrderedSame){
        return [WeiboSDK handleOpenURL:url delegate:delegate];
    }
    return NO;
    
}

@end
