   
local sdkConfig = {}
sdkConfig.initTab = {
    [TFSdk.SDK_NAME] = "pp",
    [TFSdk.APP_ID] = "4095",--[paramtype:string]
    [TFSdk.APP_KEY] = "bb0c660eb3e8224aaca348af3f7dfec6", --[paramtype:string]
    [TFSdk.APP_AMOUNT] = 12,  --[paramtype:int]--设定充值页面默认充值数额，默认为10
    --[[
        brief     设定打印SDK日志
        note      发布时请务必改为false
        paramtype     true为开启，false为关闭
     ]]
    [TFSdk.IS_NSLOG_DATA] = false,

     --[[
        brief  设置游戏客户端与游戏服务端链接方式【如果游戏服务端能主动与游戏客户端交互。例如发放道具则为长连接。此处设置影响充值并兑换的方式】
        paramtype  true 游戏通信方式为长链接，false 游戏通信方式为长链接
     ]]
    [TFSdk.IS_LONG_COMET] = true,
     
     --[[
        brief    设置注销用户后是否弹出的登录页面
        paramtype    true为自动弹出登页面，false为不弹出登录页面
     ]]
    [TFSdk.IS_LOGOUT_PUSH_LOGINVIEW] = false,
     
     --[[
        brief     是否开启充值功能
        paramtype    true为开启，false为关闭
     ]]
    [TFSdk.IS_OPEN_RECHARGE] = false,
     
     --[[
        brief     设置关闭充值提示语
        param     关闭充值时弹窗的提示语
        paramtype :string
     ]]
    [TFSdk.CLOSE_RECHARGE_ALERT_MESSAGE] = "暂未开放", 
     
    [TFSdk.DEVICE_ORIENTATION] = 2,   --[int]设定sdk方向，0 home键在下，1 home键在左边，2 home键在右边，3 home键在上

    [TFSdk.SERVER_CHECK_URL]  = "http://113.107.167.42:8002/",
    }

sdkConfig.payTab ={
    [TFSdk.ORDER_NO] ="ID",
    [TFSdk.PRODUCT_ID]="ppppppp",
    [TFSdk.PRODUCT_PRICE]="1",
    [TFSdk.SERVER_ID]="0",
    [TFSdk.ROLE_ID]="0",
}

return sdkConfig