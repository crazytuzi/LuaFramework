local sdkConfig = {
    [TFSdk.APP_ID] = "140", --[paramtype:string]
    [TFSdk.APP_KEY] = "279401ED3DB693BF8BA1694737DF79F1", --[paramtype:string]
    [TFSdk.DEVICE_ORIENTATION] = 0,   --[int]设定sdk方向，0 home键在下，1 home键在左边，2 home键在右边，3 home键在上
    [TFSdk.AUTO_CHECK_APP_UPDATE_ENABLED] = false,    --版本更新窗口加入强制选项,true时开启自动检查更新,false时关闭自动检查更新
    [TFSdk.FORCE_UPDATE] = false,             --true时更新提示窗口仅有确认更新选择项,false时用户可选择即时更新或稍候更新
    [TFSdk.IS_AUTO_ROTATE] = false,           --设置是否自动旋转(弃用)，请在RootViewController中控制是否旋转
    [TFSdk.SERVER_CHECK_URL]  = "http://119.147.247.248:9002/",

}

sdkConfig.payTab ={
    [TFSdk.ORDER_NO] ="ID",
    [TFSdk.PRODUCT_PRICE]="1",
}
return sdkConfig