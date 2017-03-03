package android.yml.com.pingpaymodule;

import android.app.Activity;
import android.content.Intent;
import android.widget.Toast;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.pingplusplus.android.Pingpp;

import java.util.HashMap;
import java.util.Map;

import javax.annotation.Nullable;

/**
 * Created by YinMenglong on 2017/3/2.
 */

public class PingPayModule extends ReactContextBaseJavaModule implements ActivityEventListener {

    private static final String ALIPAY = "ALIPAY";
    private static final String WXPAY = "WXPAY";

    public PingPayModule(ReactApplicationContext reactContext) {
        super(reactContext);
        reactContext.addActivityEventListener(this);
    }

    @Override
    public String getName() {
        return "DRPingPP";
    }

    @Nullable
    @Override
    public Map<String, Object> getConstants() {
        final Map<String, Object> constants = new HashMap<>();
        constants.put(ALIPAY, 3);
        constants.put(WXPAY, 4);
        return constants;
    }

    /**
     * 是否开启收集日志
     *
     * @param isDebug
     */
    @ReactMethod
    public void enableDebugLog(boolean isDebug) {
        Pingpp.enableDebugLog(isDebug);
    }

    private Callback callback = null;

    @ReactMethod
    public void createPayment(String charge, String appId, Callback callback) {
        Toast.makeText(getReactApplicationContext(), "去支付跳转", Toast.LENGTH_SHORT).show();
        Pingpp.createPayment(getCurrentActivity(), charge);
        this.callback = callback;
    }


    @Override
    public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {

        //支付页面返回处理
        if (requestCode == Pingpp.REQUEST_CODE_PAYMENT) {
            if (resultCode == Activity.RESULT_OK) {

                 /* 处理返回值
                 * "success" - 支付成功
                 * "fail"    - 支付失败
                 * "cancel"  - 取消支付
                 * "invalid" - 支付插件未安装（一般是微信客户端未安装的情况）
                 * "unknown" - app进程异常被杀死(一般是低内存状态下,app进程被杀死)
                 */

                String result = data.getExtras().getString("pay_result");
                String message = "支付成功";

                if (result.equals("success")) {
                    this.callback.invoke("success", message);
                } else {
                    if (result.equals("invalid")) {
                        message = "支付插件未安装";
                    } else if (result.equals("cancel")) {
                        message = "取消支付";
                    } else {
                        message = "支付失败";
                    }
                    this.callback.invoke("err", message);
                }

//                String errorMsg = data.getExtras().getString("error_msg"); // 错误信息
//                String extraMsg = data.getExtras().getString("extra_msg"); // 错误信息
            }
        }
    }


    @Override
    public void onNewIntent(Intent intent) {

    }
}
