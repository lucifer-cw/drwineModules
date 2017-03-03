import React, {Component} from 'react'
import {NativeModules} from 'react-native';

let DROauth = NativeModules.ThirdOAuthModule;
let DRPingPP = NativeModules.DRPingPP;

export
{
    DROauth,
    DRPingPP
}