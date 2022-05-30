local SDKTkData = {}
local SDK_GLOBAL_NAME = "sdk.SDKTkData"
local SDK_CLASS_NAME = "DSTalkingData"
local initOk = false

if device.platform == "android" then
	SDK_CLASS_NAME = "com/douzi/common/SDKTkData"
end

local sdk = "" .. SDK_GLOBAL_NAME
SDKTkData.m_tkID = ""

function SDKTkData.onStart()
	initOk = true
	--[[
	if device.platform == "ios" then
		if CSDKShell.getYAChannelID() == CHANNELID.IOS_APP_HANS then
			initOk = true
		end
		if TargetPlatForm == PLATFORMS.TW or TargetPlatForm == PLATFORMS.VN then
			initOk = false
		end
		if initOk == true then
			luaoc.callStaticMethod(SDK_CLASS_NAME, "setVerboseLogDisabled")
			local appID = "118a6f9cdbf8468e8f7e5cbc250d99ab"
			SDKTkData.m_tkID = appID
			local args = {appID = appID, channelId = "AppStore"}
			luaoc.callStaticMethod(SDK_CLASS_NAME, "initWithDictionary", args)
		end
	elseif device.platform == "android" then
	end
	]]
end

function SDKTkData.onRegister(param)
	--[[
	if initOk == true then
		if device.platform == "ios" then
			luaoc.callStaticMethod(SDK_CLASS_NAME, "onRegister", param)
		elseif device.platform == "android" then
		end
	end
	]]
end

function SDKTkData.onLogin(param)
	--[[
	if initOk == true then
		if device.platform == "ios" then
			luaoc.callStaticMethod(SDK_CLASS_NAME, "onLogin", param)
		elseif device.platform == "android" then
		end
	end
	]]
end

function SDKTkData.onCreateRole(param)
	--[[
	if initOk == true then
		if device.platform == "ios" then
			luaoc.callStaticMethod(SDK_CLASS_NAME, "onCreateRole", param)
		elseif device.platform == "android" then
		end
	end
	]]
end

function SDKTkData.onPay(param)
	--[[
	if initOk == true then
		if device.platform == "ios" then
			local args = param
			luaoc.callStaticMethod(SDK_CLASS_NAME, "onPay", args)
		elseif device.platform == "android" then
		end
	end
	]]
end

function SDKTkData.onPlaceOrder(param)
	--[[
	if initOk == true then
		if device.platform == "ios" then
			local args = {
			orderId = param.orderId,
			total = param.total,
			currencyType = param.currencyType,
			account = param.account
			}
			luaoc.callStaticMethod(SDK_CLASS_NAME, "onPlaceOrder", args)
		elseif device.platform == "android" then
		end
	end
	]]
end

function SDKTkData.onOrderPaySucc(param)
	--[[
	if initOk == true then
		if device.platform == "ios" then
			local args = param
			luaoc.callStaticMethod(SDK_CLASS_NAME, "onOrderPaySucc", args)
		elseif device.platform == "android" then
		end
	end
	]]
end

function SDKTkData.getDeviceId()
	--[[
	if initOk == true then
		if device.platform == "ios" then
			luaoc.callStaticMethod(SDK_CLASS_NAME, "getDeviceId")
		elseif device.platform == "android" then
		end
	end
	]]
end

function SDKTkData.onCustEvent(index)
	--[[
	if initOk == true then
		if device.platform == "ios" then
			luaoc.callStaticMethod(SDK_CLASS_NAME, "onCustEvent" .. index)
		elseif device.platform == "android" then
		end
	end
	]]
end

function SDKTkData.getTkID()
	return SDKTkData.m_tkID
end

return SDKTkData