local sdkConfig = {
    [TFSdk.APP_ID] = "140359", --[paramtype:string]
    [TFSdk.IS_CONTINUE_WHEN_CHECKUPDATE_FAILED]  = true,  --[paramtype:bool]检查更新失败后是否允许进入游戏(网络不通或服务器异常可能导致检测失败)若为允许，可能导致玩家跳过强制更新，一般情况下建议不允许
    [TFSdk.DEVICE_ORIENTATION] = 0,   --[paramtype:int]设定sdk方向，0 home键在下，1 home键在左边，2 home键在右边，3 home键在上
    [TFSdk.IS_AUTO_ROTATE] = false,            --[paramtype:bool]设置是否自动旋转，默认开启自动旋转（横屏转横屏，竖屏转竖屏）
    [TFSdk.SERVER_CHECK_URL]  = "http://119.147.247.248:9002/",
}

sdkConfig.payTab ={
    [TFSdk.ORDER_NO] ="ID",
    [TFSdk.PRODUCT_PRICE]="22221",
    [TFSdk.PRODUCT_DESCRIPTION]="sdfdasfdas",
}
return sdkConfig