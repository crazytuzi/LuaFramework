local SDKNdCom = {}
GameStateManager = require("game.GameStateManager")
local SDK_GLOBAL_NAME = "sdk.SDKNdCom"
local SDK_CLASS_NAME = "SDKDoSdkCom"
local sdk = "" .. SDK_GLOBAL_NAME

local onEnterPlatform = function()
	CCDirector:sharedDirector():pause()
end

local onLeavePlatform = function()
	CCDirector:sharedDirector():resume()
end

function SDKNdCom.initPlatform()
	luaoc.callStaticMethod(SDK_CLASS_NAME, "initPlatform")
end

function SDKNdCom.init()
	luaoc.callStaticMethod(SDK_CLASS_NAME, "initSdk")
	local sdk_ = {
	callbacks = {}
	}
	sdk = sdk_
	SDK_GLOBAL_NAME = sdk
	local function callback(event)
		dump("## SDKNdCom CALLBACK, event " .. tostring(event))
		for name, callback in pairs(sdk.callbacks) do
			callback(event)
		end
		onLeavePlatform()
	end
	dump(sdk.callbacks)
	luaoc.callStaticMethod(SDK_CLASS_NAME, "registerScriptHandler", {listener = callback})
end

function SDKNdCom.cleanup()
	sdk.callbacks = {}
	luaoc.callStaticMethod(SDK_CLASS_NAME, "unregisterScriptHandler")
end

function SDKNdCom.addCallback(name, callback)
	dump(name)
	dump(callback)
	sdk.callbacks[name] = callback
end

function SDKNdCom.removeCallback(name)
	sdk.callbacks[name] = nil
end

function SDKNdCom.login()
	return luaoc.callStaticMethod(SDK_CLASS_NAME, "login")
end

function SDKNdCom.regist(info)
	local ok = luaoc.callStaticMethod(SDK_CLASS_NAME, "Regist", {info}, "(Ljava/util/HashMap;I)V;")
	if ok then
		printf("Regist ok!!")
	end
end

function SDKNdCom.setDebug(param)
	local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "setDebug", {debug = param})
	assert(ok, string.format("SDKNdCom.setDebug() - call API failure, error code: %s", tostring(ret)))
	return ret
end

function SDKNdCom.onLogout(cleanAutoLogin)
	return luaoc.callStaticMethod(SDK_CLASS_NAME, "logout")
end

function SDKNdCom.isLogined()
	local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "isLogined")
	assert(ok, string.format("SDKNdCom.isLogined() - call API failure, error code: %s", tostring(ret)))
	return ret
end

function SDKNdCom.getUserinfo()
	local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "getUserinfo")
	assert(ok, string.format("SDKNdCom.getUserinfo() - call API failure, error code: %s", tostring(ret)))
	return ret
end

function SDKNdCom.getVersion()
	local ok, version = luaoc.callStaticMethod(SDK_CLASS_NAME, "getVersion")
	assert(ok, string.format("SDKNdCom.getVersion() - call API failure, error code: %s", tostring(version)))
	return version
end

function SDKNdCom.getChannelId()
	local ok, channelId = luaoc.callStaticMethod(SDK_CLASS_NAME, "getChannelId")
	assert(ok, string.format("SDKNdCom.getChannelId() - call API failure, error code: %s", tostring(channelId)))
	return channelId
end

function SDKNdCom.switchAccount()
	local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "switchAccount")
	assert(ok, string.format("SDKNdCom.switchAccount() - call API failure, error code: %s", tostring(ret)))
end

function SDKNdCom.enterPlatform()
	local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "enterPlatform")
	assert(ok, string.format("SDKNdCom.enterPlatform() - call API failure, error code: %s", tostring(ret)))
end

function SDKNdCom.showToolbar(...)
	local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "showToolbar")
	assert(ok, string.format("SDKNdCom.showToolbar() - call API failure, error code: %s", tostring(ret)))
	return ret
end

function SDKNdCom.HideToolbar(...)
	local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "HideToolbar")
	assert(ok, string.format("SDKNdCom.HideToolbar() - call API failure, error code: %s", tostring(ret)))
	return ret
end

function SDKNdCom.payForCoins(param)
	local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "payForCoins", param)
	assert(ok, string.format("SDKNdCom.payForCoins() - call API failure, error code: %s", tostring(ret)))
	return ret
end

function SDKNdCom.openAdvertisement()
	local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "openAdvertisement")
	assert(ok, string.format("SDKNdCom.openAdvertisement() - call API failure, error code: %s", tostring(ret)))
end

function SDKNdCom.submitExtData(info)
	local ok, ret = luaoc.callStaticMethod(SDK_CLASS_NAME, "submitExtData", info)
	assert(ok, string.format("SDKNdCom.submitExtData() - call API failure, error code: %s", tostring(ret)))
	return ret
end

return SDKNdCom