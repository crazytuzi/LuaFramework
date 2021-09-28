--
--                   _ooOoo_
--                  o8888888o
--                  88" . "88
--                  (| -_- |)
--                  O\  =  /O
--               ____/`---'\____
--             .'  \\|     |//  `.
--            /  \\|||  :  |||//  \
--           /  _||||| -:- |||||-  \
--           |   | \\\  -  /// |   |
--           | \_|  ''\---/''  |   |
--           \  .-\__  `-`  ___/-. /
--         ___`. .'  /--.--\  `. . __
--      ."" '<  `.___\_<|>_/___.'  >'"".
--     | | :  `- \`.;`\ _ /`;.`/ - ` : | |
--     \  \ `-.   \_ __\ /__ _/   .-` /  /
--======`-.____`-.___\_____/___.-`____.-'======
--                   `=---='
--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
--                 Buddha bless
--
-- 日期：14-12-12
--

SDKHelper = {}

require("gamecommon")
require("constant.channelid")
require("data.data_serverurl_serverurl")
require("data.data_msg_push_msg_push")
require("sdk.SDKType")

local SDK_CLASS_NAME = "com/douzi/common/SDKCom"
SDKHelper.SDKTYPES = {
    IOS_91       = "IOS_91",		-- 91助手
    IOS_PP       = "IOS_PP",		-- pp助手
    IOS_TB       = "IOS_TB",		-- 同步推
    IOS_ITOOLS   = "IOS_ITOOLS",	-- ITOOLS
    IOS_KUAIYONG = "IOS_KUAIYONG",  -- 快用
    IOS_APPSTORE = "IOS_APPSTORE",	-- AppStore
    IOS_XY		 = "IOS_XY", 		-- XY
    IOS_AS 		 = "IOS_AS", 		-- 爱思助手
    IOS_HM       = "IOS_HM",        -- 海马助手
    IOS_OTHER    = "IOS_OTHER"

}

hasInited = false

function SDKHelper.getChannelID()
    return GetChannelID(SDKHelper.GetBoundleID())
end

--[[
	版本标识
		发送给服务器，作为除了channelid之外的第2更新标识
	ios:
		100: 上线版本
		101: 开发版本
		102: 渠道评测包
		103: 保留
]]
function SDKHelper.getBuildFlag(  )
    local buildFlags = {100, 101, 102}
    local buildFlag = buildFlags[1]
    if(CHANNEL_BUILD == false) then
        --开发版本
        if(DEV_BUILD == true)then
            buildFlag = buildFlags[2]
        end
    elseif(CHANNEL_BUILD == true) then
        --渠道评测包
        buildFlag = buildFlags[3]
    end
    return buildFlag
end


function SDKHelper.init( ... )
--
    SDKHelper.SDK_TYPE = SDKHelper.GetBoundleID()
--
--    local boundleID = SDKHelper.GetBoundleID( )
--
--    if(boundleID == "com.fy.rxqz.baidu") then
--        SDKHelper.SDK_TYPE = SDKHelper.SDKTYPES.IOS_91 			-- ios91
--        channelid = CHANNELID.IOS_91
--    elseif(boundleID == "com.douzi.dawuxia") then
--        device.platform = "windows"
--    end
    print("SDKTYPE:   " .. tostring(SDKHelper.SDK_TYPE))
    print("ChannelID: " .. tostring(SDKHelper.getChannelID()))
    print("boundleID: " .. tostring(SDKHelper.GetBoundleID()))

    SDKHelper.initPlatform(checkint(SDKHelper.getChannelID()))

    SDKHelper.initPushNotice()
end

function SDKHelper.getSDKIdFromServer( ... )
    local isFromServer = false
    if SDKHelper.GetSDKTYPE() == SDKType.ANDROID_360 then
        isFromServer = true
    end
    return isFromServer
end

local function  logout()
    dump("SDK_NOT_LOGINED")
    GameStateManager:ChangeState( GAME_STATE.STATE_VERSIONCHECK )
    SDKHelper.onLogout()
end


--SDKHelper.setLogffEvent()


local function noticeForLua(event)
    CCNotificationCenter:sharedNotificationCenter():postNotification(event);
end

function SDKHelper.initPlatform(channelid)
    local appId = data_serverurl_serverurl[channelid].appid or ""
    local appKey = data_serverurl_serverurl[channelid].appkey or ""

    CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(display.newNode(), logout, "SDK_NOT_LOGINED")
	if ANDROID_DEBUG then
		printf("initPlatform ok!!")
		return
	end
    local ok = luaj.callStaticMethod(SDK_CLASS_NAME, "initPlatform", {tostring(appId), tostring(appKey), noticeForLua}, "(Ljava/lang/String;Ljava/lang/String;I)V");
    if ok then
        printf("initPlatform ok!!")
    end
end

function SDKHelper.Login(loginType)
	if ANDROID_DEBUG then
		printf("login ok!!")
		return
	end
    local ok = luaj.callStaticMethod(SDK_CLASS_NAME, "login", {loginType or 0}, "(I)V");
    if ok then
        printf("login ok!!")
    end
end

SDKHelper.isLoginedOK = false
function SDKHelper.isLogined( ... )
	if ANDROID_DEBUG then
		return SDKHelper.isLoginedOK
	end
    local ok, ret = luaj.callStaticMethod(SDK_CLASS_NAME, "isLogined", {}, "()I");
    if ok then
        if 1 == ret then
            return true
        end
    end
    dump(ret)
    return false
end

function SDKHelper.logout( ... )

end

function SDKHelper.onLogout()
	if ANDROID_DEBUG then
		printf("logout")
		return
	end
    local ok = luaj.callStaticMethod(SDK_CLASS_NAME, "onLogout")
    if ok then
        printf("logout")
    end
end

function SDKHelper.loginEx( ... )

end

function SDKHelper.enterAppBBS( ... )
    local ok = luaj.callStaticMethod(SDK_CLASS_NAME, "enterBBS");
    if ok then
        printf("enterAppBBS!!")
    end
end

function SDKHelper.enterPlatform( ... )
    local ok = luaj.callStaticMethod(SDK_CLASS_NAME, "enterPlatform");
    if ok then
        printf("enterPlatform!!")
    end
end

function SDKHelper.userFeedback( ... )
    local ok = luaj.callStaticMethod(SDK_CLASS_NAME, "userFeedback");
    if ok then
        printf("userFeedback!!")
    end
end

function SDKHelper.payForCoins( coins )

end


function SDKHelper.BuyCoins( coins, price )

end

--0 支付成功， 1 支付失败， -2 支付进行中, 4010201和4009911 登录状态已失效，引导用户重新登录
--    0:成功
--    1:失败
--    2:支付进行中
--    3:登录状态失效，请重新登陆进行支付
--    4:取消支付
--    5:下单成功，是否充值成功依赖服务器
local function payResult(event)

    local function resultFunc() 
        local str = ""
        event = checknumber(event)
        if 0 == event then
            str = "支付成功"
            PostNotice(NoticeKey.CommonUpdate_PAY_RESULT, CCString:create("SDKNDCOM_PAY_SUCCESS"))
        elseif 1 == event then
    --        str = "支付失败"
            PostNotice(NoticeKey.CommonUpdate_PAY_RESULT, CCString:create("SDKNDCOM_PAY_FAILED"))
        elseif 2 == event then
            str = "支付进行中"
            PostNotice(NoticeKey.CommonUpdate_PAY_RESULT, CCString:create("SDKNDCOM_PAY_WAITCHECK"))
        elseif 4 == event then
    --        str = "取消支付"
            PostNotice(NoticeKey.CommonUpdate_PAY_RESULT, CCString:create("SDKNDCOM_PAY_FAILED"))
        elseif 5 == event then
            PostNotice(NoticeKey.CommonUpdate_PAY_RESULT, CCString:create("SDKNDCOM_PAY_WAITCHECK"))
            str = ""
        else
            str = "支付异常，稍后重试"
        end

        printf("============== payResult: " .. str)
        if #str > 0 then
            show_tip_label(str)
        end
    end 

    if CSDKShell.GetSDKTYPE() == SDKType.ANDROID_YW then
        game.runningScene:performWithDelay(function()
            resultFunc()
        end, 2)
    else
        resultFunc()
    end
end

--asyCallback:应用宝专用，充值成功后，需要请求服务器扣币
function SDKHelper.BuyAsynCoins(param, asyCallback)
    dump(param)
    if SDKHelper.isLogined() then
        local tmp = {}
        for k, v in pairs(param) do
            if type(v) == "number" or type(v) == "string" then
                tmp[k] = tostring(v)
            end
        end

        local callback
        if asyCallback then
            callback = function(result)
                asyCallback(payResult, result)
            end
        else
            callback = payResult
        end

        local ok, ret = luaj.callStaticMethod(SDK_CLASS_NAME, "asynPay", {tmp, callback}, "(Ljava/util/HashMap;I)Ljava/util/HashMap;");
        if ok then
            printf("BuyAsynCoins!!")
            return ret
        end
    else
        SDKHelper.Login()
    end
end

SDKHelper.userInfoData = {}
function SDKHelper.userInfo()
	if ANDROID_DEBUG then
		local ret = SDKHelper.userInfoData
		ret.platformID = SDKHelper.getChannelID()
		return ret
	end
    local ok, ret = luaj.callStaticMethod(SDK_CLASS_NAME, "getUserinfo", {}, "()Ljava/util/HashMap;");
    if ok then
        ret.platformID = SDKHelper.getChannelID()
        dump(ret)
        return ret
    end
--
    return nil
end

function SDKHelper.pause(f)
    local arg = {}
    if f then
        arg[1] = f
    else
        arg[1] = function()

        end
    end
	if luaj ~= nil then
		luaj.callStaticMethod(SDK_CLASS_NAME, "pause", arg, "(I)V");
	end
end

function SDKHelper.back(f)
    local arg = {}
    if f then
        arg[1] = f
    else
        arg[1] = function()
            CCDirector:sharedDirector():endToLua()
        end
    end
	if luaj ~= nil then
		luaj.callStaticMethod(SDK_CLASS_NAME, "back", arg, "(I)V");
	end
end

function SDKHelper.showToolbar()
	if luaj ~= nil then
		luaj.callStaticMethod(SDK_CLASS_NAME, "showToolBar");
	end
end

function SDKHelper.HideToolbar()
	if luaj ~= nil then
		luaj.callStaticMethod(SDK_CLASS_NAME, "hideToolBar");
	end
end

function SDKHelper.addEventCallBack( name ,callback )
    if "payEvent" == name then
        UnRegNotice(game.runningScene, NoticeKey.CommonUpdate_PAY_RESULT)
        RegNotice(game.runningScene,
            function(event, obj)
                printf("payEvent")
                callback(tolua.cast(obj, "CCString"):getCString())
                UnRegNotice(game.runningScene, NoticeKey.CommonUpdate_PAY_RESULT)
            end,
            NoticeKey.CommonUpdate_PAY_RESULT)
    end

end

function SDKHelper.delEventCallBack( name )

end

function SDKHelper.SetSDKTYPE( type )
    SDKHelper.SDK_TYPE = type
end

function SDKHelper.GetSDKTYPE( ... )
    return SDKHelper.GetBoundleID()
end

function SDKHelper.getBaseUrlByChannelId()
    local _loginUrl = data_serverurl_serverurl[SDKHelper.getChannelID()].loginUrl
    if(DEV_BUILD == true) then
        _loginUrl = data_serverurl_serverurl[SDKHelper.getChannelID()].loginUrldev
    end
    return _loginUrl
end

function SDKHelper:getIapUrlByChannelId()
    local _loginUrl = data_serverurl_serverurl[SDKHelper.getChannelID()].loginUrl
    if(DEV_BUILD == true) then
        _loginUrl = data_serverurl_serverurl[SDKHelper.getChannelID()].loginUrldev
    end

    local bIndex, _ = string.find(_loginUrl, "/", 8)
    if bIndex then
        _loginUrl = string.sub(_loginUrl, 1, bIndex - 1)
    end

    return _loginUrl
end



function SDKHelper:getIapNotifyUrlByChannelId()
    local _loginUrl = data_serverurl_serverurl[SDKHelper.getChannelID()].payUrl
    if(DEV_BUILD == true) then
        _loginUrl = data_serverurl_serverurl[SDKHelper.getChannelID()].payUrldev
    end
    return _loginUrl
end

--[[

	获取设备信息
]]
function SDKHelper.GetDeviceInfo( ... )
	if ANDROID_DEBUG then
		return {}
	end
    local ok, ret = luaj.callStaticMethod(SDK_CLASS_NAME, "getDeviceInfo", {}, "()Ljava/util/HashMap;")
    if ok then
        printf("OK")
    end
    printf("+++++++++++++++++++++++++++++++++++++++++++++")
    dump(ret)
    return ret or {}
end

--roleId: 玩家角色ID
--roleName: 玩家角色名
--roleLevel: 玩家角色等级
--zoneId: 游戏区服ID
--zoneName: 游戏区服名称
function SDKHelper.submitExtData(param)
    local info = {
        roleId    = game.player.m_uid,
        roleName  = game.player:getPlayerName(),
        roleLevel = game.player:getLevel(),
        zoneId    = game.player.m_serverID,
        zoneName  = game.player.m_serverName,
        isNewUser = param.isNewUser or false,
        isLevelUp = param.isLevelUp or false,
        vipLevel  = game.player:getVip(),
        goldCount = game.player:getGold(),
        gender = game.player:getGender(),
        newZoneId = game.player.m_zoneID --新数字服务器id
    }
    dump(info)
	if luaj ~= nil then
		local ok = luaj.callStaticMethod(SDK_CLASS_NAME, "submitExtData", {info}, "(Ljava/util/HashMap;)V")
		if ok then
			printf("OK")
		end
	end
end

function SDKHelper.initPushNotice()
	if ANDROID_DEBUG then
		printf("initPushNotice ok!!")
		return
	end
    for k, v in pairs(data_msg_push_msg_push) do
        local info = {
            time = tostring(v.time),
            title= v.title or "吃鸡了",
            msg = v.text,
            id = tostring(v.id)
        }
        local ok = luaj.callStaticMethod(SDK_CLASS_NAME, "addPushNotice", {info}, "(Ljava/util/HashMap;)V")
        if ok then
            printf("OK")
        end
    end

end

function SDKHelper.GetBoundleID()
    if ANDROID_DEBUG then
		return SDKType.WXDZS
	end
    local ok, ret = luaj.callStaticMethod(SDK_CLASS_NAME, "getPackageName", {}, "()Ljava/lang/String;");
    if ok then
        local b, _ = string.find(ret, SDKType.ANDROID_YW)
        if b then
            return SDKType.ANDROID_YW
        else
            return ret
        end
    end
    return nil
end

function SDKHelper.EnterGame()

end

return SDKHelper


