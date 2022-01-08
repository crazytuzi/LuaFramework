--配置信息键值
 local SDK = {
    STATISTICS_NAME = "statistics_name",--all sdk
    SDK_NAME="sdk_name", --all sdk
    APP_ID = "AppId",  --PP kuaiyong ITools IPay TB
    APP_KEY = "AppKey", --PP ITools IPay CY
    APP_AMOUNT = "AppAmount",  --设定充值页面默认充值数额，默认为10  --pp

    APP_SECRECT = "AppSecrect", --CY
    --[[
    检查更新失败后是否允许进入游戏(网络不通或服务器异常可能导致检测失败)若为允许，可能导致玩家跳过强制更新，一般情况下建议不允许
    ]]
    IS_CONTINUE_WHEN_CHECKUPDATE_FAILED  = "isContinueWhenCheckUpdateFailed",  --TB

    --[[
    版本更新窗口加入强制选项,true时开启自动检查更新,false时关闭自动检查更新 
    ]]
    AUTO_CHECK_APP_UPDATE_ENABLED = "AutoCheckAppUpdateEnabled", --ITools

    --[[
    true时更新提示窗口仅有确认更新选择项,false时用户可选择即时更新或稍候更新
     ]]   
    FORCE_UPDATE = "ForceUpdate",    --ITools                               

    --[[
        brief     设定打印SDK日志
        note      发布时请务必改为false
        param     true为开启，false为关闭
     ]]
    IS_NSLOG_DATA = "IsNSlogData",--PP

    --[[
        设置是否自动旋转，默认开启自动旋转（横屏转横屏，竖屏转竖屏）
    ]]
    IS_AUTO_ROTATE = "IsAutoRotate",           --TB

     --[[
        brief  设置游戏客户端与游戏服务端链接方式【如果游戏服务端能主动与游戏客户端交互。例如发放道具则为长连接。此处设置影响充值并兑换的方式】
        param  true 游戏通信方式为长链接，false 游戏通信方式为长链接
     ]]
    IS_LONG_COMET = "IsLongComet",--PP
     
     --[[
        brief    设置注销用户后是否弹出的登录页面
        param    true为自动弹出登页面，false为不弹出登录页面
     ]]
    IS_LOGOUT_PUSH_LOGINVIEW = "IsLogOutPushLoginView", --PP
     
     --[[
        brief     是否开启充值功能
        param    true为开启，false为关闭
     ]]
    IS_OPEN_RECHARGE = "IsOpenRecharge", --PP
     
     --[[
        brief     设置关闭充值提示语
        param     关闭充值时弹窗的提示语
     ]]
    CLOSE_RECHARGE_ALERT_MESSAGE = "CloseRechargeAlertMessage", --PP
    
    --[[
        设定sdk方向，0 home键在下，1 home键在左边，2 home键在右边，3 home键在上
    ]] 
    DEVICE_ORIENTATION = "DeviceOrientation",   --PP KY ITools TB IPay

    --购买信息类键值
    ORDER_NO = "OrderNo",   --订单号，订单号长度请勿超过30位  PP  KY ITools TB CY
    PRODUCT_NAME = "ProductName",   --商品名称   PP CY
    PRODUCT_PRICE = "ProductPrice",  --商品价格，价格必须为大于等于1的int类型  PP ITools TB
    PAY_DESCRIPTION = "ProductDescription",    --支付描述，发送支付成功通知时，返回给开发者 TB
    ROLE_ID = "RoleId",              --角色id，回传参数若无请填0  PP CY
    SERVER_ID = "ServerId",              --开发者中心后台配置的分区id，若无请填写0  PP
    GAME = "game",                   --http://payquery.bppstore.com上面对应ID KY
    GAMESVR = "gamesvr",             --多个通告地址的选择设置  KY
    SUBJECT = "subject",             --传空   KY
    MD5KEY = "md5Key",               --http://payquery.bppstore.com该网址对应的密匙  KY
    URLSCHEME = "urlScheme",         --支付宝快捷支付对应的回调应用名称，要与targets-》info-》url types中的 url schemes中设置的对应  KY
    ORDER_EXTRAL_INFO = "OrderExtralInfo",    --商户可使⽤用该字段对该订单设置私有信息 --IPay
    PRODUCT_ID = "ProductId",            --注册商品的商品编码,由平台分配的商品编号  --IPay CY
    PRODUCT_COUNT = "ProductCount",    -- 一次购买该商品的数量,默认为 1 --IPay CY
    PRODUCT_REGISTER_ID = "ProductRegId", --CY
    CHANNEL_ID = "ChannelId",--CY
    DEBUG_MODE = "DebugMode",--CY
    --回调事件键值
    EVENT_ID = "EventID",    --回调事件名称，包括（SDK_LOGIN，SDK_LOGOUT，SDK_PAYFORPRODUCT，SDK_LEAVEPLATFORM）PP KY ITools TB
    RESULT_CODE ="Result",   --回调结果：0 表示成功， 1 表示失败， 2 表示取消，3 表示待验证 PP KY ITools TB
    RESULT_MSG ="ResultMsg", --回调结果描述  PP KY ITools TB
    SESSION_ID ="SessionId", --客户端登陆返回的会话ID或token  PP KY ITools TB
    USER_ID ="UserId",       --登陆用户ID  PP KY ITools TB
    USER_NAME ="UserName",   --登陆用户名  PP KY ITools TB
    
    --以下UM统计sdk用到
    TJCASH  ="cash",      --真实币数量
    TJSOURCE = "source",  --支付渠道或者奖励渠道,作为支付渠道（1到8）时：1:appStore 2:支付宝 3:网银 4:财付通 5:移动通信 6:联通通信 7:电信通信 8:paypal 作为奖励渠道（1到10）时，1被预定义为系统奖励,其他需要在网站设置
    TJITEM ="item",      --道具名称
    TJAMOUNT ="amount", -- 道具数量
    TJPRICE = "price", -- 道具单价
    TJCOIN = "coin", --虚拟币数量
    TJAGE ="age",   -- 年龄
    TJSEX ="sex", --性别
    TJLEVEL="level", --等级或者是关卡id
    TJUSERID="userId", --玩家id
    TJPLATFORM ="platform",--来源
    TJBLOGENABLE ="bLogEnable",--开启log

    SHARE_URL ="shareUrl";
    SHARE_NAME ="name";
    SHARE_CAPTION ="caption";
    SHARE_PICTURE_URL ="pictureUrl";
    SHARE_DESCRIPTION ="description";    
    SHARE_STYLE ="shareSytle";
    SHARE_STYLE_API = 0;
    SHARE_STYLE_WEB_DIALOG = 1;

    FRIENDS_STLYE= "FriendStlye";
    FRIENDS_IDS= "FriendIds";
    FRIENDS_INVITE_TITLE= "InviteTitle";
    FRIENDS_INVITE_MSG= "InviteMsg";

    FRIENDS_GET_NORMAL= 0;
    FRIENDS_GET_INVITE= 1;
}

local skdFun = TFLuaOcJava.callStaticMethod
local SDK_CLASS_NAME = "SDK"

--[[--

初始化
-   SDK_LOGIN 登录完成
-   SDK_LOGOUT 登出完成
-   SDK_PAYFORPRODUCT 支付完成
-   SDK_LEAVEPLATFORM 离开平台
]] 
function SDK.init()
    local infoTab = require('sdkConfig.sdkInfo')
    print("SDK Init-------------start")
    if infoTab.initTab[TFSdk.SDK_NAME] == nil then return end
    if infoTab.initTab[TFSdk.STATISTICS_NAME] and type(infoTab.initTab[TFSdk.STATISTICS_NAME]) == 'string' and #infoTab.initTab[TFSdk.STATISTICS_NAME] > 1 then
        TFSdk.bStatistics     = true --[bool]是否有第三方统计
        TFSdk.szStatisticsName = infoTab.initTab[TFSdk.STATISTICS_NAME] --[string] --统计插件的类名
    else
        TFSdk.bStatistics     = false --[bool]是否有第三方统计
    end

    TFSdk.initTab = infoTab.initTab
    TFSdk.payTab  = infoTab.payTab
    local function callback(event)
        if SDK.callbacks then
            SDK.callbacks(event)
        end
    end
    print("SDK Init-------------end")
    skdFun(SDK_CLASS_NAME, "registerScriptHandler", {listener = callback})
    skdFun(SDK_CLASS_NAME, "initSDK", TFSdk.initTab)
end

function SDK.addCallback(callbackFun)
    SDK.callbacks = callbackFun
end

function SDK.removeCallback()
    SDK.callbacks = nil
end

function SDK.login()
    skdFun(SDK_CLASS_NAME, "login")
end

function SDK.logout()
    skdFun(SDK_CLASS_NAME, "logout")
end

function SDK.enterPlatform()
    skdFun(SDK_CLASS_NAME, "enterPlatform")
end

function SDK.payForProduct(table)
    skdFun(SDK_CLASS_NAME, "payForProduct",table)
end

function SDK.getProductList()
    skdFun(SDK_CLASS_NAME, "getProductList")
end

function SDK.enterRechargeRecord()
    skdFun(SDK_CLASS_NAME, "enterRechargeRecord")
end

function SDK.getSdkVersion()
    local ret,ver = skdFun(SDK_CLASS_NAME, "getSdkVersion")
    if ret then 
        return ver
    end

    return nil
end

function SDK.setAutoLogin(bAuto)
    skdFun(SDK_CLASS_NAME, "setAutoLogin",{autoLogin = bAuto})
end

function SDK.onEventID(szEventID)
    local sdkName = TFSdk:getSdkName()
    if not sdkName or sdkName ~= "changyou" then return end

    skdFun(SDK_CLASS_NAME, "onEventActionID",{eventID = szEventID})
end

-- Add by Hiver 14.12.2
function SDK.share(table)
    skdFun(SDK_CLASS_NAME, "share",table)
end

-- Add by Hiver 14.12.2
function SDK.getFriends(table)
    skdFun(SDK_CLASS_NAME, "getFriends",table)
end

-- Add by Hiver 14.12.2
function SDK.inviteFriends(table)
    skdFun(SDK_CLASS_NAME, "inviteFriends",table)
end

return SDK
