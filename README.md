# drwineModules 包含以下模块
 DRPingPP  Ping++支付
 ThirdOAuthModule  第三方授权登录


#ios DRPingPP配置 
#--主项目 Copy Bundle Resources 添加bundle
AlipaySDK.bundle                           react-native-drwine/ios/Channels/Alipay
TencentOpenApi_IOS_Bundle                  react-native-drwine/ios/OauthSDK
WeiboSDK.bundle                            react-native-drwine/ios/OauthSDK/sina
Pingpp.bundle                              react-native-drwine/ios/

#--主项目 Link Binary With Libraries 添加 相关依赖库
UIKit.framework,CoreFoundation.framework,CoreMotion.framework,CoreTelephony.framework,QuartzCore.framework,Security.framework,SystemConfiguration.famework,CFNetwork.famework
AlipaySDK.framework,TencentOpenApi.framework

libstdc++.tbd,
libsqlite3.0.tbd,
libz.tbd,
libc++.tbd,
libbz2.1.0.tbd

Framework Search Paths 添加
$(SRCROOT)/../node_modules/react-native-drwine/ios/Channels/Alipay
$(SRCROOT)/../node_modules/react-native-drwine/ios/OauthSDK


# android DRPingPP 配置

1.android/settings.gradle  中添加
include ':react-native-drwine'
project(':react-native-drwine').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-drwine/android')

2.app/build.gradle
dependencies {
compile project(':react-native-vector-icons')
compile project(':react-native-drwine')
}

3.app/src/main/java/com/drwine/android
import android.yml.com.pingpaymodule.ExampleReactPackage;
protected List<ReactPackage> getPackages() {
return Arrays.<ReactPackage>asList(
new MainReactPackage(),
new ExampleReactPackage()
);
}


#-- DRPingPP 使用
import {DRPingPP} from 'react-native-drwine';
DRPingPP.createPayment({charge}, 'appid/scheme',(err)=>{
if(err){
Alert.alert('支付失败'+err);
}else {
Alert.alert('支付成功'+err);
}
});

*appid:
*scheme:URL Scheme，支付宝渠道回调需要
