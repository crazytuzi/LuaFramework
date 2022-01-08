local sdk     = require('TFFramework.SDK.ios.TFSdkFunction')
local TFSdkIos = {}
setmetatable(TFSdkIos, sdk)
sdk.__index = sdk

TFSdkIos.serverToken     = nil -- [string]校验服务器返回的token
TFSdkIos.platformToken   = nil -- [string]渠道登录时返回的token
TFSdkIos.uId             = nil -- [string]第三方渠道用户ID
TFSdkIos.uName           = nil -- [string]第三方渠道用户昵称
TFSdkIos.initPlatformCallBack = nil --[function]初始化sdk完成回调
TFSdkIos.loginInCallBack  = nil --[function]登陆结果回调
TFSdkIos.loginOutCallBack = nil --[function]登出回调
TFSdkIos.payForProductCallBack = nil --[function]支付回调
TFSdkIos.leavePlatCallBack = nil  --[function] 离开平台回调
TFSdkIos.initTab = nil        --[table] init需要的参数配置表
TFSdkIos.payTab  = nil        --[table] payForProduct需要的参数配置表
TFSdkIos.bHasInited = false     --[bool] 是否初始化过
TFSdkIos.bHasLoginIn = false    --[bool] 是否已经登录了sdk
TFSdkIos.bGetServerListOk = false   --[bool] 获取区服列表结果
TFSdkIos.bServerCheckOK = false    --[bool] server check 结果
TFSdkIos.SERVER_CHECK_URL = "serverCheckURL" --用于提交到校验服务器校验sdk登录的有效性
TFSdkIos.bStatistics     = false --[bool]是否有第三方统计
TFSdkIos.szStatisticsName = nil --[string] --统计插件的类名
TFSdkIos.getProductListCallBack = nil --[function]获取商品列表
TFSdkIos.enterRechargeRecordCallBack = nil --[function]进入充值记录
TFSdkIos.shareCallBack =nil --[function]分享结果回调
TFSdkIos.getgameserverCallBack =nil --[function]分享结果回调
TFSdkIos.getFriendsCallBack =nil --[function]获取好友结果回调  Facebook
TFSdkIos.inviteFriendsCallBack =nil --[function]邀请好友结果回调  Facebook

local skdFun = TFLuaOcJava.callStaticMethod

TFSdkIos.loginResultTab = {
        result         = -1, --[(-1001):server check failed (-1002):get Server list error]
        msg            = nil,
        gameServers    = {},
        lastGameServer = {},
    }

function TFSdkIos.eventDispatch(result)

    local resultTab=
    {
        result=result.Result,
        msg=result.ResultMsg
    }


    if result.EventID == "SDK_LOGIN" then
        TFSdkIos:loginSDKCallBack(result)
    elseif result.EventID == "SDK_LOGOUT" and TFSdkIos.loginOutCallBack ~= nil then
        TFSdkIos.bHasLoginIn = false
        TFSdkIos.bServerCheckOK = false
        TFSdkIos.bGetServerListOk  = false
        TFSdkIos.loginResultTab.gameServers=nil
        TFSdkIos.loginOutCallBack(resultTab)
    elseif result.EventID == "SDK_PAYFORPRODUCT" and TFSdkIos.payForProductCallBack ~= nil then
        resultTab["productList"]=result.GoodsInfo
        TFSdkIos.payForProductCallBack(resultTab)  --change by baohong.li
    elseif result.EventID =="SDK_LEAVEPLATFORM" and TFSdkIos.leavePlatCallBack ~= nil then
        TFSdkIos.leavePlatCallBack(resultTab)
    elseif result.EventID == "SDK_INIT_PLATFORM" then
        TFSdkIos:initSDKCallBack(result)
    elseif result.EventID == "SDK_GET_PRODUCT_LIST" and TFSdkIos.getProductListCallBack ~= nil then
        TFSdkIos.getProductListCallBack(resultTab);
    elseif result.EventID == "SDK_SHARE" and TFSdkIos.shareCallBack ~= nil then
        TFSdkIos.shareCallBack(resultTab)
    elseif result.EventID == "SDK_GET_FRIENDS" and TFSdkIos.getFriendsCallBack ~= nil then
        local pData  = TFStringUtils:urlDecodeUtf8(result.FriendList)
        if result.Result==0 then
            resultTab["FriendList"]=json.decode(pData)
        end
        TFSdkIos.getFriendsCallBack(resultTab)
    elseif result.EventID == "SDK_INVITE_FRIENDS" and TFSdkIos.inviteFriendsCallBack ~= nil then
        TFSdkIos.inviteFriendsCallBack(resultTab)
    end
end

--获取区服列表回调 
function TFSdkIos.getServerListCallBack(eventType,statusCode,pData)
    -- body
    if TFSdkIos.loginInCallBack then
        if statusCode == 200 then
            pData  = TFStringUtils:urlDecodeUtf8(pData)
            TFSdkIos.loginResultTab = json.decode(pData)
            TFSdkIos.bGetServerListOk = true
            if TFSdkIos.loginResultTab.result ~= 0 then
                TFSdkIos.loginResultTab.result = -1002
            end
        end
        if TFSdkIos.loginResultTab.result ~= 0 then
            TFSdkIos.loginResultTab.result = -1002
            TFSdkIos.bGetServerListOk = false
            TFSdkIos.loginResultTab.msg = "get server list error"
        end
        TFSdkIos.loginInCallBack(TFSdkIos.loginResultTab)
    end
end

--获取区服列表  will first check server--callback param tab
--[[
    TFSdkIos.loginResultTab = {
        result         = -1,
        msg            = nil,
        gameServers    = {},
        lastGameServer = {},
    }
]]
function TFSdkIos:getServerList()
    -- body
    if not TFSdkIos.bServerCheckOK then
        TFSdkIos:serverCheck()
    else
        local url   = TFSdkIos.initTab[TFSdkIos.SERVER_CHECK_URL].."getgameserver"
        local table = {
            ["uin"]        = TFSdkIos.uId,
            ["platform"]   = TFSdkIos.initTab[TFSdkIos.SDK_NAME],
            ["token"]      = TFSdkIos.serverToken,
        }
        local insHttp = TFClientNetHttp:GetInstance()
        local content = json.encode(table)
        insHttp:setMaxRecvSec(30)
        insHttp:addMERecvListener(TFSdkIos.getServerListCallBack)
        insHttp:httpRequest(TFHTTP_TYPE_POST,url,content)
    end
end

--校验服务器验证回调
function TFSdkIos.serverCheckCallBack(eventType,statusCode,pData)
    -- body
    if TFSdkIos.loginInCallBack then
        if statusCode == 200 then
            pData  = TFStringUtils:urlDecodeUtf8(pData)
            local retTab = json.decode(pData)
            TFSdkIos.serverToken = retTab.token
            TFSdkIos.uId = retTab.uin
            TFSdkIos.uName = retTab.uname
            if retTab.result == 0 then
                TFSdkIos.bServerCheckOK = true
                TFSdkIos:getServerList()
                do return end
            end
        end
        
        print("===check fail will clear uid===")
        TFSdkIos.uId = 0
        TFSdkIos.setAutoLogin(false)
        TFSdkIos.bServerCheckOK = false
        TFSdkIos.loginResultTab.result = -1001
        TFSdkIos.loginResultTab.msg ="server check fail"
        TFSdkIos.loginInCallBack(TFSdkIos.loginResultTab)
    end
end

function TFSdkIos.setAutoLogin(bAuto)
    sdk.setAutoLogin(bAuto)
end

function TFSdkIos:serverCheck()
    if TFSdkIos.initTab[TFSdkIos.SERVER_CHECK_URL] == nil or TFSdkIos.initTab[TFSdkIos.SDK_NAME] == nil  then
        TFSdkIos.loginResultTab.msg ="server check fail SERVER_CHECK_URL or SDK_NAME maybe nil"
        return TFSdkIos.serverCheckCallBack(nil,nil,nil)
    end

    local url               = TFSdkIos.initTab[TFSdkIos.SERVER_CHECK_URL].."login"
    local table = {
        ["uin"]             = TFSdkIos.uId,
        ["uname"]           = TFSdkIos.uName,
        ["platform"]        = TFSdkIos.initTab[TFSdkIos.SDK_NAME],
        ["platformToken"]   = TFSdkIos.platformToken or "",
        ["appId"]           = TFSdkIos.initTab[TFSdkIos.APP_ID] or "0",
        ["deviceId"]        = TFDeviceInfo.getMachineOnlyID() or "",
        ["iosDeviceToken"]  = TFDeviceInfo.getDeviceToken() or "",
    }

    local insHttp = TFClientNetHttp:GetInstance()
    local content = json.encode(table)
    insHttp:setMaxRecvSec(30)
    insHttp:addMERecvListener(TFSdkIos.serverCheckCallBack)
    insHttp:httpRequest(TFHTTP_TYPE_POST,url,content)
end




--callback param "SDK_INIT_PLATFORM"
function TFSdkIos:init(callback)
    if TFSdkIos.bHasInited then return end
    if callback then 
        if type(callback) == 'function' then
            TFSdkIos.initPlatformCallBack = callback
        else
            print("=====init===callback=error",callback)
            return
        end
    end

    TFSdkIos.bHasInited = true
    sdk.addCallback(TFSdkIos.eventDispatch)
    sdk.init()
end

-- 初始化成功则会自动登录，否则会返回失败结果
function TFSdkIos:initSDKCallBack(result)
    if TFSdkIos.initPlatformCallBack then
        local  resultTab = {
                result = result.Result,
                msg = result.ResultMsg,
            }
        TFSdkIos.initPlatformCallBack(resultTab);
    else
        sdk.login()
    end
end

--sdk 登录结果回调后，此回调根据结果处理
--Result:0 登录sdk成功，自动链接校验服务器验证反之则将结果返回游戏逻辑
function TFSdkIos:loginSDKCallBack(pData)
    print("loginSDKCallBack:",pData)
    if pData.Result == 0 then
        TFSdkIos.bHasLoginIn = true
        TFSdkIos.platformToken     = pData.SessionId
        TFSdkIos.uId               = pData.UserId or ""
        TFSdkIos.uName             = pData.UserName or ""
        TFSdkIos:getServerList()
    else
        TFSdkIos.loginResultTab.result = pData.Result
        TFSdkIos.loginResultTab.msg    = pData.ResultMsg
        TFSdkIos.bHasLoginIn = false
        if TFSdkIos.loginInCallBack then
            TFSdkIos.loginInCallBack(TFSdkIos.loginResultTab)
        end
    end
end

-- callback  param tab 
--[[
    TFSdkIos.loginResultTab = {
        result         = -1,
        msg            = nil,
        gameServers    = {},
        lastGameServer = {},
    }
]]
function TFSdkIos:login(callback)
    if TFSdkIos.bHasLoginIn then return end

    if callback then
        if type(callback) == 'function' then
            TFSdkIos.loginInCallBack = callback
        else
            print("=====login===callback=error",callback)
        end
    end
    if TFSdkIos.bHasInited == false then
        TFSdkIos:init()
    else
        sdk.login()
    end
end

function TFSdkIos:logout(callback)
    if callback then
        if type(callback) == 'function' then
            TFSdkIos.loginOutCallBack = callback
        else
            print("=====logout===callback=error",callback)
            return
        end
    end
    TFSdkIos.bHasLoginIn = false
    sdk.logout()
end

--productTab 对应字段后面标注的sdk名称表明该sdk支付需要用到该字段
--[[
    tab[ORDER_NO] ="9659479" IPay ITools KY TB PP
    tab[PRODUCT_PRICE]=5.23  IPay ITools KY TB PP
    tab[GAME]="4179"         KY
    tab[GAMESVR]=""          KY
    tab[SUBJECT]="subject"   KY
    tab[MD5KEY]="tJhHxB9dLruhb4NxKOvV6tCZisZgQ0ij" KY
    tab[URLSCHEME]="com.playmore.sexymaidky" KY
    tab[ORDER_EXTRAL_INFO]="ppppppp"      IPay
    tab[PRODUCT_AMOUNT]=1                 IPay
    tab[PRODUCT_ID]="1"                   IPay  APPStone
    tab[PAY_DESCRIPTION]="ppppppp"    TB
    tab[PRODUCT_NAME]="ppppppp"           PP
    tab[ROLE_ID]=0                        PP
    tab[ZONE_ID]=0                        PP
    
    --facebook 需要以下字段
    tab[NAME]="ttttttttttttttt",
    tab[CAPTION] = "Build great social apps and get more installs.",
    tab[DESCRIPTION] = "Allow your users to share stories on Facebook from your app using the iOS SDK.",
    tab[LINK] = "https://developers.facebook.com/docs/ios/share/",
    tab[PICTURE] = "http://i.imgur.com/g3Qc1HN.png"
]]

function TFSdkIos:payForProduct(productTab,callback)
    if callback then
        if type(callback) == 'function' then
            TFSdkIos.payForProductCallBack = callback
        else
            print("=====payForProduct===callback=error",callback)
            return
        end
    end
    sdk.payForProduct(productTab)
end

function TFSdkIos:switchAccount(callback)
    return
end

function TFSdkIos:enterPlatform()
   sdk.enterPlatform()
end

--callback param tab 
--[[
    TFSdkIos.loginResultTab = {
        result         = -1,
        msg            = nil,
        gameServers    = {},
        lastGameServer = {},
    }
]]
function TFSdkIos:setLoginInCallBack(callback)
    if type(callback) == 'function' then
        TFSdkIos.loginInCallBack = callback
    else
        print("=====setLoginInCallBack===callback=error",callback)
    end
end

--callback param "SDK_LOGOUT"
function TFSdkIos:setLogoutCallback(callback)
    if type(callback) == 'function' then
        TFSdkIos.loginOutCallBack = callback
    else
        print("=====setLogoutCallback===callback=error",callback)
    end
end

--callback param "SDK_LEAVEPLATFORM"
function TFSdkIos:setLeavePlatformCallback(callback)
    if type(callback) == 'function' then
        TFSdkIos.leavePlatCallBack = callback
    else
        print("=====setLeavePlatformCallback===callback=error",callback)
    end
end

function TFSdkIos:setAppID(szAppID)
    TFSdkIos.APP_ID = szAppID
end

function TFSdkIos:setSdkName(szName)
    TFSdkIos.SDK_NAME = szName
end

function TFSdkIos:setPlatformToken(szToken)
    TFSdkIos.platformToken = szToken
end

function TFSdkIos:setUserID(szID)
    TFSdkIos.uId = szID
end

function TFSdkIos:setUserName(szName)
    TFSdkIos.uName = szName
end

function TFSdkIos:getSdkName()
    if not TFSdkIos.initTab then return nil end
    return TFSdkIos.initTab[TFSdkIos.SDK_NAME]
end

function TFSdkIos:getPlatformToken()
    return TFSdkIos.platformToken
end

function TFSdkIos:getUserID()
    return TFSdkIos.uId
end

function TFSdkIos:getUserName()
    return TFSdkIos.uName
end

function TFSdkIos:getCheckServerToken()
    return TFSdkIos.serverToken
end

function TFSdkIos:getUserIsLogin()
    return TFSdkIos.bHasLoginIn
end

function TFSdkIos:getServerListResult()
    return TFSdkIos.bGetServerListOk
end

function TFSdkIos:getServerCheckResult()
    return TFSdkIos.bServerCheckOK
end

function TFSdkIos:getProductList(callback)
    if callback then
        if type(callback) == 'function' then
            TFSdkIos.getProductListCallBack = callback
        else
            print("=====getProductList===callback=error",callback)
            return
        end
    end
    sdk.getProductList()
end

function TFSdkIos:enterRechargeRecord()
    sdk.enterRechargeRecord()
end

function TFSdkIos:getSdkVersion(callback)
        if callback then
        if type(callback) == 'function' then
            callback(sdk.getSdkVersion())
        else
            print("=====getSdkVersion===callback=error",callback)
            return
        end
    end
end
--以下为统计插件使用
--充值
--[[
um table = {
    [TFSdk.TJCASH] = double,
    [TFSdk.TJSOURCE] = int,
    [TFSdk.TJCOIN] = double,
 }
]]
function TFSdkIos:recharge(tTable)
    if not TFSdkIos.bStatistics then return end
    skdFun(TFSdkIos.szStatisticsName, "recharge",tTable)
end

--充值并购买
--[[
um table = {
    [TFSdk.TJCASH ]= double,
    [TFSdk.TJSOURCE] = int,
    [TFSdk.TJITEM ]= string,
    [TFSdk.TJAMOUNT] = int,
    [TFSdk.TJPRICE ]= double,
 }
]]
function TFSdkIos:rechargeAndBuy(tTable)
    if not TFSdkIos.bStatistics then return end
    skdFun(TFSdkIos.szStatisticsName, "rechargeAndBuy",tTable)
end

--购买道具
--[[
um tabl = {
    [TFSdk.TJITEM] = string,
    [TFSdk.TJAMOUNT] = int,
    [TFSdk.TJPRICE ]= double,
}
]]
function TFSdkIos:buyProp(tTable)
    if not TFSdkIos.bStatistics then return end
    skdFun(TFSdkIos.szStatisticsName, "buyProp",tTable)
end

--使用道具
--[[
um tabl = {
    [TFSdk.TJITEM] = string,
    [TFSdk.TJAMOUNT] = int,
    [TFSdk.TJPRICE] = double,
}
]]
function TFSdkIos:useProp(tTable)
    if not TFSdkIos.bStatistics then return end
    skdFun(TFSdkIos.szStatisticsName, "useProp",tTable)
end

--赠送金币
--[[
um tabl = {
    [TFSdk.TJCOIN] = double,
    [TFSdk.TJSOURCE] = int,
}
]]
function TFSdkIos:bonusGold(tTable)
    if not TFSdkIos.bStatistics then return end
    skdFun(TFSdkIos.szStatisticsName, "bonusGold",tTable)
end

--赠送道具
--[[
um table = {
    [TFSdk.TJITEM ]= string,
    [TFSdk.TJAMOUNT ]= int,
    [TFSdk.TJPRICE ]= double,
    [TFSdk.TJSOURCE] = int,
}
]]

function TFSdkIos:bonusProp(tTable)
    if not TFSdkIos.bStatistics then return end
    skdFun(TFSdkIos.szStatisticsName, "bonusProp",tTable)
end

--进入关卡
--[[
um table = {
    [TFSdk.TJLEVEL ]= string,
}
]]
function TFSdkIos:startLevel(tTable)
    if not TFSdkIos.bStatistics then return end
    skdFun(TFSdkIos.szStatisticsName, "startLevel",tTable)
end

--通过关卡
--[[
um table = {
    [TFSdk.TJLEVEL] = string,
}
]]
function TFSdkIos:finishLevel(tTable)
    if not TFSdkIos.bStatistics then return end
    skdFun(TFSdkIos.szStatisticsName, "finishLevel",tTable)
end

--未通过关卡
--[[
um table = {
    [TFSdk.TJLEVEL] = string,
}
]]
function TFSdkIos:failLevel(tTable)
    if not TFSdkIos.bStatistics then return end
    skdFun(TFSdkIos.szStatisticsName, "failLevel",tTable)
end

--设置玩家等级
--[[
um table = {
    [TFSdk.TJLEVEL ]= string,
}
]]
function TFSdkIos:setUserLevel(tTable)
    if not TFSdkIos.bStatistics then return end
    skdFun(TFSdkIos.szStatisticsName, "setUserLevel",tTable)
end

--设置玩家属性
--[[
um table = {
    [TFSdk.TJUSERID] = string,
    [TFSdk.TJSEX]= int,
    [TFSdk.TJAGE]= int,
    [TFSdk.TJPLATFORM]= string,
}
]]
function TFSdkIos:setUserInfo(tTable)
    if not TFSdkIos.bStatistics then return end
    skdFun(TFSdkIos.szStatisticsName, "setUserInfo",tTable)
end

--设置log开关
--[[
um table = {
    [TFSdk.TJBLOGENABLE] = bool,
}
]]
function TFSdkIos:setLogEnable(tTable)
    if not TFSdkIos.bStatistics then return end
    skdFun(TFSdkIos.szStatisticsName, "setLogEnable",tTable)
end

--自定义事件（畅游）
--szEvent EVENT_ID
function TFSdkIos:onEventActionID(szEventID)
    sdk.onEventID(szEventID)
end

function TFSdkIos:share(shareTab,callback)
    if callback then
        if type(callback) == 'function' then
            TFSdkIos.shareCallBack = callback
        else
            print("=====share===callback=error",callback)
            return
        end
    end
    sdk.share(shareTab)
end

function TFSdkIos:getFriends(getTab,callback)
    if callback then
        if type(callback) == 'function' then
            TFSdkIos.getFriendsCallBack = callback
        else
            print("=====share===getFriends=error",callback)
            return
        end
    end
    sdk.getFriends(getTab)
end

function TFSdkIos:inviteFriends(inviteTab,callback)
    if callback then
        if type(callback) == 'function' then
            TFSdkIos.inviteFriendsCallBack = callback
        else
            print("=====share===inviteFriends=error",callback)
            return
        end
    end
    sdk.inviteFriends(inviteTab)
end


return TFSdkIos

