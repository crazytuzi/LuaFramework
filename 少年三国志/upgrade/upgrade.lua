--upgrade.lua
require("upgrade.Patcher")

cache_old_loadsting = loadstring 
local sharedApplication = CCApplication:sharedApplication()
local target = sharedApplication:getTargetPlatform()
if USE_FLAT_LUA == nil or USE_FLAT_LUA == "0" then 
	if target == kTargetIphone or target == kTargetIpad or target == kTargetAndroid or target == kTargetWindows or target == kTargetMacOS then
		FuncHelperUtil:loadChunkWithKeyAndSign("framework_precompiled.zip", "7631A09609C74180", "9D10F6DE-4E81-4ADC-817A-B381783AE639")
	end
end 

if target ~= kTargetIphone and target ~= kTargetIpad and target ~= kTargetAndroid and target ~= kTargetWindows then
	--require("upgrade.config")
	--require("cocos.init")
end

require("upgrade.VersionUtils")

--nativeProxy 是对原生的各种调用
G_NativeProxy = require("upgrade.NativeProxy").new()
G_NativeProxy.registerNativeCallback( function(data) print("nativeProxy nil callback") end)

CCDirector:sharedDirector():runWithScene(require("upgrade.UpgradeScene").new())



