local sdkConfig = {}
sdk.initTab =
{
    [TFSdk.APP_ID] = "3000257557", --[paramtype:string]
    [TFSdk.APP_KEY] = "RjQwMjBFNjMxMURBMkU3MkZFMzYwQzFCNDQ1MTgzNTg5NDJBN0QyNE1UWXhPVEV6TXpFd09EQTFNVEk1TVRnNE56a3JNalF3T1RnNE9UYzVPRGMyTURnek1qRTRNRGt5TnpnMU9ETTBNRGc1TkRjeE16QXhOVFl4", --[paramtype:string]
    [TFSdk.DEVICE_ORIENTATION] = 0,   --[int]设定sdk方向，0 home键在下，1 home键在左边，2 home键在右边，3 home键在上
    [TFSdk.SERVER_CHECK_URL]  = "http://119.147.247.248:9002/",
}

sdkConfig.payTab ={
    [TFSdk.ORDER_NO] ="ID",
    [TFSdk.PRODUCT_ID]="ppppppp",
    [TFSdk.PRODUCT_COUNT]="1",
    [TFSdk.ORDER_EXTRAL_INFO]="sdfasfas",
}
return sdkConfig