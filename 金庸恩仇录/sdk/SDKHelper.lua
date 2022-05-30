SDKHelper = {}
require("data.data_channelid")
require("data.data_url")
local SDK_CLASS_NAME = "com/sdk/SDK"
hasInited = false

SDKHelper.userInfoData = {}

function SDKHelper.getChannelID()
	if device.platform == "mac" or device.platform == "windows" then
		return "com.win32.wuxia"
	end
	local boundleID = SDKHelper.GetBoundleID()
	return boundleID
end

function SDKHelper.getYAChannelID()
	local ok, ret = luaj.callStaticMethod(SDK_CLASS_NAME, "getChannelID", {}, "()Ljava/lang/String;")
	if ok then
		return ret
	end
end

function SDKHelper.init()
	SDKHelper.SetSDKTYPE(SDKHelper.GetBoundleID())
	dump("SDKTYPE:   " .. tostring(SDKHelper.SDK_TYPE))
	dump("ChannelID: " .. tostring(SDKHelper.getChannelID()))
	dump("boundleID: " .. tostring(SDKHelper.GetBoundleID()))
	SDKHelper.initPlatform()
	SDKHelper.initPushNotice()
end

function SDKHelper.isInit()
	local ok, ret = luaj.callStaticMethod(SDK_CLASS_NAME, "isInit", {}, "()I")
	if ok and 1 == ret then
		return true
	end
	return false
end

function SDKHelper.getGameDebugFlag()
	local ok, ret = luaj.callStaticMethod(SDK_CLASS_NAME, "getGameDebugFlag", {}, "()I")
	if ok then
		return ret
	end
	return 100
end

local noticeForLua = function(event)
	dump(event)
	if event == "SDKDOSDKCOM_NOT_LOGINED" then
		GameStateManager:ChangeState(GAME_STATE.STATE_VERSIONCHECK)
	elseif event == "SDKDOSDKCOM_INIT_PLATFORM" then
		hasInited = true
	elseif event == "SDKDOSDKCOM_LOGOUT" then
		GameStateManager:ChangeState(GAME_STATE.STATE_VERSIONCHECK)
	else
		CCNotificationCenter:sharedNotificationCenter():postNotification(event)
	end
end

function SDKHelper.initPlatform(channelid)
	local ok = luaj.callStaticMethod(SDK_CLASS_NAME, "initPlatform", {noticeForLua}, "(I)V")
	if ok then
		printf("initPlatform ok!!")
	end
end

function SDKHelper.Login(loginType)
	local ok = luaj.callStaticMethod(SDK_CLASS_NAME, "login", {
	loginType or 0
	}, "(I)V")
	if ok then
		printf("login ok!!")
	end
end

function SDKHelper.Regist(info)
	local ok = luaj.callStaticMethod(SDK_CLASS_NAME, "regist", {info}, "(Ljava/util/HashMap;I)V;")
	if ok then
		printf("Regist ok!!")
	end
end

function SDKHelper.isLogined()
	local ok, ret = luaj.callStaticMethod(SDK_CLASS_NAME, "isLogined", {}, "()I")
	if ok and 1 == ret then
		return true
	end
	dump(ret)
	return false
end

function SDKHelper.setDebug(_debug)
	local ok = luaj.callStaticMethod(SDK_CLASS_NAME, "setDebug", {_debug}, "(I)V")
	if ok then
		printf("setDebug ok!!")
	end
end

function SDKHelper.onLogout()
	local ok = luaj.callStaticMethod(SDK_CLASS_NAME, "onLogout")
	if ok then
		printf("logout")
	end
end

function SDKHelper.loginEx(...)
end

function SDKHelper.enterAppBBS(...)
	local ok = luaj.callStaticMethod(SDK_CLASS_NAME, "enterBBS")
	if ok then
		printf("enterAppBBS!!")
	end
end

function SDKHelper.enterPlatform(...)
	local ok = luaj.callStaticMethod(SDK_CLASS_NAME, "enterPlatform")
	if ok then
		printf("enterPlatform!!")
	end
end

function SDKHelper.userFeedback(...)
	local ok = luaj.callStaticMethod(SDK_CLASS_NAME, "userFeedback")
	if ok then
		printf("userFeedback!!")
	end
end

local payResult = function(event)
	local function resultFunc()
		event = checknumber(event)
		if 0 == event then
			PostNotice(NoticeKey.CommonUpdate_PAY_RESULT, "SDKDOSDKCOM_PAY_SUCCESS")
		elseif 2 == event then
			PostNotice(NoticeKey.CommonUpdate_PAY_RESULT, "SDKDOSDKCOM_PAY_CANCEL")
		else
			PostNotice(NoticeKey.CommonUpdate_PAY_RESULT, "SDKDOSDKCOM_PAY_FAILED")
		end
	end
	resultFunc()
end

function SDKHelper.payForCoins(param)
	dump(param)
	if SDKHelper.isLogined() then
		local tmp = {}
		for k, v in pairs(param) do
			if type(v) == "number" or type(v) == "string" then
				tmp[k] = tostring(v)
			end
		end
		local ok, ret = luaj.callStaticMethod(SDK_CLASS_NAME, "payForCoins", {tmp, payResult}, "(Ljava/util/HashMap;I)Ljava/util/HashMap;")
		if ok then
			printf("payForCoins!!")
			return ret
		end
	else
		SDKHelper.Login()
	end
end

function SDKHelper.purchase(param)
	dump(param)
	local ok, ret = luaj.callStaticMethod(SDK_CLASS_NAME, "purchase", {
	param or 0
	}, "(I)V")
	if ok then
		printf("purchase!!")
		return ret
	end
end

function SDKHelper.userInfo()
	local ok, ret = luaj.callStaticMethod(SDK_CLASS_NAME, "getUserinfo", {}, "()Ljava/util/HashMap;")
	if ok then
		ret.platformID = SDKHelper.getChannelID()
		dump(ret)
		return ret
	end
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
	luaj.callStaticMethod(SDK_CLASS_NAME, "pause", arg, "(I)V")
end

function SDKHelper.showToolbar()
	luaj.callStaticMethod(SDK_CLASS_NAME, "showToolBar")
end

function SDKHelper.HideToolbar()
	luaj.callStaticMethod(SDK_CLASS_NAME, "hideToolBar")
end

function SDKHelper.addEventCallBack(name, callback)
	if "payEvent" == name then
		UnRegNotice(game.runningScene, NoticeKey.CommonUpdate_PAY_RESULT)
		RegNotice(game.runningScene, function(event, obj)
			printf("payEvent")
			callback(obj)
			UnRegNotice(game.runningScene, NoticeKey.CommonUpdate_PAY_RESULT)
		end,
		NoticeKey.CommonUpdate_PAY_RESULT)
	end
end

function SDKHelper.delEventCallBack(name)
end

function SDKHelper.SetSDKTYPE(_type)
	SDKHelper.SDK_TYPE = _type
end

function SDKHelper.GetSDKTYPE(...)
	return SDKHelper.GetBoundleID()
end

function SDKHelper.switchAccount()
	local ok, ret = luaj.callStaticMethod(SDK_CLASS_NAME, "switchAccount", {}, "()V")
	if ok then
		printf("OK")
	end
end

function SDKHelper.GetDeviceInfo(...)
	local ok, ret = luaj.callStaticMethod(SDK_CLASS_NAME, "getDeviceInfo", {}, "()Ljava/util/HashMap;")
	if ok then
		printf("OK")
	end
	dump(ret)
	return ret or {}
end

function SDKHelper.submitExtData(param)
	local info = {
	roleId = game.player.m_uid,
	roleName = game.player:getPlayerName(),
	roleLevel = game.player:getLevel(),
	zoneId = game.player.m_zoneID,
	zoneName = game.player.m_serverName,
	isNewUser = param.isNewUser or false,
	isLevelUp = param.isLevelUp or false,
	vipLevel = game.player:getVip(),
	goldCount = game.player:getGold(),
	gender = game.player:getGender(),
	newZoneId = game.player.m_serverID,
	playerId = game.player:getPlayerID(),
	token = game.player.m_extendData.token,
	puid = game.player.m_uid
	}
	dump(info.zoneId, "submitExtData data")
	dump(info)
	local ok = luaj.callStaticMethod(SDK_CLASS_NAME, "submitExtData", {info}, "(Ljava/util/HashMap;)V")
	if ok then
		printf("OK")
	end
end

function SDKHelper.initPushNotice()
	data_msg_push_msg_push = require("data.data_msg_push_msg_push")
	for k, v in pairs(data_msg_push_msg_push) do
		local info = {
		time = tostring(v.time),
		title = v.title or common:getLanguageString("@chijile"),
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
	local ok, ret = luaj.callStaticMethod(SDK_CLASS_NAME, "getPackageName", {}, "()Ljava/lang/String;")
	printf("getPackageName:%s, is ok1:%s", tostring(ret), tostring(ok))
	if ok then
		return ret
	end
	return nil
end

function SDKHelper.exit()
	os.exit()
end

function SDKHelper.EnterGame()
end

function SDKHelper.getVersion()
	local ok, ret = luaj.callStaticMethod(SDK_CLASS_NAME, "getDoSDKVersion", {}, "()Ljava/lang/String;")
	if ok then
		return ret
	end
	return ""
end

function SDKHelper.getAD()
	local ok, ret = luaj.callStaticMethod(SDK_CLASS_NAME, "getAD", {}, "()Ljava/lang/String;")
	if ok then
		return ret
	end
	return ""
end

return SDKHelper