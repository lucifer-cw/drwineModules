import React, {Component} from 'react'
import {NativeModules} from 'react-native';

let Oauth = NativeModules.ThirdOAuthModule;
let PingPay = NativeModules.PingPayModule;

export
{
    Oauth,
    PingPay
}
