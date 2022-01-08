--[[
SDK代理类


]]

TFPlugins = {}

if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
    TFPlugins = require("TFFramework.Plugins.TFPluginsBase")
elseif CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
    TFPlugins = require("TFFramework.Plugins.TFPluginsBase")
else
	TFPlugins = require('TFFramework.Plugins.win32.TFPluginsWin32')
end

-- 如果手机 为母包则使用空的sdk
if CC_TARGET_PLATFORM ~= CC_PLATFORM_WIN32 then
	if TFPlugins.isPluginExist() == false then
		TFPlugins = require('TFFramework.Plugins.win32.TFPluginsWin32')
	end
end

-- 黑桃URL
local serverList_url = "http://106.12.125.116:9000/server/list.do"

-- win为测试环境
if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then
	serverList_url = "http://106.12.125.116:9000/server/list.do"
	serverList_url = "http://106.12.125.116:9000/server/list.do"
end

serverList_url = "http://106.12.125.116/server/list.php"


if TFPlugins.isPluginExist() then
	serverList_url = serverList_url .. "?channel=" .. TFPlugins.getChannelId()
end

print("--- TFPlugins init ----- serverList_url = ", serverList_url)

-- 用户中心地址
TFPlugins.serverList_url = serverList_url

-- appstore 资源更新地址
TFPlugins.versionPath = "http://106.12.125.116/mhqx/appstore/"
TFPlugins.filePath    = "http://106.12.125.116/mhqx/appstore/source/"
TFPlugins.zipCheckPath= "http://106.12.125.116/mhqx/appstore/"

-- win为测试环境
if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then
    TFPlugins.versionPath = "192.168.10.115/mhqx/"
    TFPlugins.filePath    = "192.168.10.115/mhqx/source/"
	TFPlugins.zipCheckPath= "192.168.10.115/mhqx/"
end

return TFPlugins