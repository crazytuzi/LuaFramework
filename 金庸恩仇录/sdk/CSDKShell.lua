require("data.data_channelid")
require("data.data_url")
GAME_3RD_PLATFORM = true
local CSDKShell = {}
local m_sdkInstance
hasInited = false
CSDKShell.userInfoData = {}
CSDKShell.isLoginedOK = false

function CSDKShell.getYAChannelID()
	return "wuxia"
	--[[
	if device.platform == "ios" then
		return m_sdkInstance.getChannelId()
	elseif device.platform == "windows" or device.platform == "mac" then
		return "wuxia"
	end
	]]
end

function CSDKShell.getChannelID()
	return "com.win32.wuxia"
	--[[
	if device.platform == "windows" or device.platform == "mac" then
		return "com.win32.wuxia"
	end
	local boundleID = CSDKShell.GetBoundleID()
	return boundleID
	]]
end

function CSDKShell.isInit()
	return hasInited
end

function CSDKShell.init()
	hasInited = true
	if device.platform == "ios" then
		--[[
		if GAME_3RD_PLATFORM == true then
			CSDKShell.SetSDKTYPE(CSDKShell.GetBoundleID())
			CSDKShell.initPlatform()
		end
		]]
	else
		hasInited = true
		CSDKShell.SetSDKTYPE("com.win32.wuxia")
	end
end

function CSDKShell.getVersion()
	return "1.0"
	--[[
	if device.platform == "ios" then
		return m_sdkInstance.getVersion()
	end
	]]
end

function CSDKShell.setDebug(_debug)
	--[[
	if device.platform == "ios" then
		return m_sdkInstance.setDebug(debug)
	end
	]]
end

function CSDKShell.initPlatform()
	--[[
	if device.platform == "ios" then
		m_sdkInstance = require("sdk.SDKNdCom")
		m_sdkInstance.init()
		local noticeForLua = function(event)
			dump(event)
			if event == "SDKDOSDKCOM_NOT_LOGINED" then
				GameStateManager:ChangeState(GAME_STATE.STATE_VERSIONCHECK)
			elseif event == "SDKDOSDKCOM_INIT_PLATFORM" then
				hasInited = true
				print("dsds=====")
			elseif event == "SDKDOSDKCOM_LOGOUT" then
				GameStateManager:ChangeState(GAME_STATE.STATE_VERSIONCHECK)
			else
				CCNotificationCenter:sharedNotificationCenter():postNotification(event)
			end
		end
		m_sdkInstance.addCallback("initEvent", noticeForLua)
		if hasInited == false then
			m_sdkInstance.initPlatform()
		end
	end
	]]
end

function CSDKShell.submitExtData(param)
	--[[
	if device.platform == "ios" then
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
		puid = game.player.m_uid,
		isPaySuc = param.isPaySuc or false
		}
		m_sdkInstance.submitExtData(info)
	end
	]]
end

function CSDKShell.Login()
	--[[
	if device.platform == "ios" then
		m_sdkInstance.login()
	end
	]]
end

function CSDKShell.regist(info)
	--[[
	m_sdkInstance.regist(info)
	]]
end

function CSDKShell.EnterGame()
	--[[
	if device.platform == "ios" and m_sdkInstance.notifyEnterGame then
		m_sdkInstance.notifyEnterGame()
	end
	]]
end

function CSDKShell.isLogined()
	if device.platform == "ios" then
		return true
		--return m_sdkInstance.isLogined()
	elseif device.platform == "windows" then
		return true
	elseif device.platform == "mac" then
		return true
	elseif device.platform == "android" then
		return true
	end
	return true
end

function CSDKShell.onLogout()
	GameStateManager:ChangeState(GAME_STATE.STATE_VERSIONCHECK)
	--[[
	if device.platform == "ios" then
		ret = m_sdkInstance.onLogout()
	elseif device.platform == "windows" then
		GameStateManager:ChangeState(GAME_STATE.STATE_VERSIONCHECK)
	end
	]]
end

function CSDKShell.loginEx()
	--[[
	if device.platform == "ios" and CSDKShell.getYAChannelID() == CHANNELID.IOS_91 then
		m_sdkInstance.loginEx()
	end
	]]
end

function CSDKShell.enterAppBBS()
	--[[
	if device.platform == "ios" and CSDKShell.getYAChannelID() == CHANNELID.IOS_91 then
		m_sdkInstance.enterAppBBS()
	end
	]]
end

function CSDKShell.enterPlatform()
	--[[
	if device.platform == "ios" then
		m_sdkInstance.enterPlatform()
	end
	]]
end

function CSDKShell.payForCoins(param)
	--[[
	if device.platform == "ios" then
		if CSDKShell.isLogined() then
			SDKTKData.onCustEvent(6)
			local ret = m_sdkInstance.payForCoins(param)
			return ret
		else
			CSDKShell.Login()
		end
	end
	]]
	return nil
end

function CSDKShell.userInfo()
	if device.platform == "ios" then
		if CSDKShell.isLogined() == true then
			return {}
			--local info = m_sdkInstance.getUserinfo()
			--info.platformID = CSDKShell.getChannelID()
			--return info
		end
	elseif device.platform == "windows" or device.platform == "mac" then
		local info = {}
		info.platformID = CSDKShell.getChannelID()
		return info
	end
	return nil
end

function CSDKShell.showToolbar()
	--[[
	if device.platform == "ios" then
		m_sdkInstance.showToolbar()
	end
	]]
end

function CSDKShell.openAdvertisement()
	--[[
	if device.platform == "ios" and (CSDKShell.getYAChannelID() == CHANNELID.IOS_APP_HANS or CSDKShell.getYAChannelID() == CHANNELID.IOS_EW_APP_HANS) then
		m_sdkInstance.openAdvertisement()
	end
	]]
end

function CSDKShell.pause()
	
end

function CSDKShell.HideToolbar()
	--[[
	if device.platform == "ios" then
		m_sdkInstance.HideToolbar()
	end
	]]
end

function CSDKShell.addEventCallBack(name, callback)
	--[[
	if device.platform == "ios" then
		m_sdkInstance.addCallback(name, callback)
	end
	]]
end

function CSDKShell.delEventCallBack(name)
	--[[
	if device.platform == "ios" then
		m_sdkInstance.removeCallback(name)
	end
	]]
end

function CSDKShell.SetSDKTYPE(_type)
	CSDKShell.SDK_TYPE = _type
end

function CSDKShell.GetSDKTYPE()
	return CSDKShell.SDK_TYPE
end

function CSDKShell.GetDeviceInfo()
	local ret = {}
	if device.platform == "ios" then
		ret.deviceUUID = "ios11"
		--local GameDevice = require("sdk.GameDevice")
		--return GameDevice.GetDeviceInfo()
	else
		ret.deviceUUID = "123456"
	end
	return ret
end

function CSDKShell.exit()
	os.exit()
end

function CSDKShell.GetBoundleID()
	if device.platform == "windows" or device.platform == "mac" then
		return "com.win32.wuxia"
	end
	if device.platform == "ios" then
		return "com.ios.wuxia"
		--local GameDevice = require("sdk.GameDevice")
		--local boundleID = GameDevice.GetBoundleID()
		--return boundleID
	end
	return "com.android.wuxia"
end

function CSDKShell.GetChannelName()
	--[[
	if device.platform == "ios" then
		return "1.0"
		--local GameDevice = require("sdk.GameDevice")
		--local _, channelName = GameDevice.GetBoundleID()
		--return channelName
	end
	]]
	return "com.ios.wuxia"
end

function CSDKShell.switchAccount()
	--[[
	if device.platform == "ios" then
		m_sdkInstance.switchAccount()
	end
	]]
end

return CSDKShell