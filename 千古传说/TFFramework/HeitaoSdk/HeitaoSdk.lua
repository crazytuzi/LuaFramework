--[[
SDK代理类


]]

HeitaoSdk = {}

if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
    HeitaoSdk = require("TFFramework.HeitaoSdk.android.HeitaoSdkAndroid")
elseif CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
    -- HeitaoSdk = require("TFFramework.HeitaoSdk.ios.HeitaoSdkIos")
    HeitaoSdk = require("TFFramework.HeitaoSdk.android.HeitaoSdkAndroid")
    -- HeitaoSdk = nil
else
	HeitaoSdk = nil
end

return HeitaoSdk