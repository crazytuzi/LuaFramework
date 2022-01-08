local sdkConfig = {
    [TFSdk.DEVICE_ORIENTATION] = 0,   --[paramtype:int]设定sdk方向，0 home键在下，1 home键在左边，2 home键在右边，3 home键在上
    [TFSdk.IS_AUTO_ROTATE] = false,        --[paramtype:bool]设置是否自动旋转，默认开启自动旋转（横屏转横屏，竖屏转竖屏）
    [TFSdk.SERVER_CHECK_URL]  = "http://119.147.247.248:9002/",
}

sdkConfig.payTab ={
    [TFSdk.ORDER_NO] ="ID",
    [TFSdk.PRODUCT_PRICE]="125432",
    [TFSdk.GAME]="ppppppp",
    [TFSdk.GAMESVR] = "http://",
    [TFSdk.SUBJECT]="45245",
    [TFSdk.MD5KEY]="lkj",
    [TFSdk.URLSCHEME]="http://",
}
return sdkConfig
