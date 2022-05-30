--[[
local debugTagFilePath = cc.FileUtils:getInstance():getWritablePath() .. "is_debug_mode.debug"
local debugTagFile = io.open(debugTagFilePath, "r")
if debugTagFile then
	debugFileContent = debugTagFile:read()
	if debugFileContent then
		print("debug file content:" .. debugFileContent)
	end
	io.close(debugTagFile)
end
]]

local rootpath = cc.FileUtils:getInstance():getWritablePath() .. "updateres/"
local path = {
"",
"res/",
"res/ui/",
"res/ccbi/",
"res/fonts/"
}

SearchPath = {}

if device.platform == "windows" or device.platform == "mac" then
	local v = cc.UserDefault:getInstance():getStringForKey("language", "Inland_android_wuxia")
	local platform_Path = "platforms/" .. v
	
	if platform_Path then
		path[#path + 1] = "scripts/"
	end
	
	if platform_Path then
		for k, v in ipairs(path) do
			table.insert(SearchPath, #SearchPath + 1, rootpath .. platform_Path .. v)
		end
	end
	
	for k, v in ipairs(path) do
		table.insert(SearchPath, #SearchPath + 1, rootpath .. v)
	end
	
	if platform_Path then
		local dirs = string.split(platform_Path, "_")
		for i, v in ipairs(dirs) do
			local platformPath = ""
			if i < #dirs then
				platformPath = table.concat(dirs, "_", 1, #dirs - i + 1)
			else
				platformPath = dirs[1]
			end
			for k, v in ipairs(path) do
				table.insert(SearchPath, #SearchPath + 1, platformPath .. "/" .. v)
			end
		end
	end
	
	for k, v in ipairs(path) do
		table.insert(SearchPath, #SearchPath + 1, v)
	end
	
else
	for k, v in ipairs(path) do
		table.insert(SearchPath, k, rootpath .. v)
		table.insert(SearchPath, #SearchPath + 1, v)
	end
end

dump(SearchPath)
for _, v in ipairs(SearchPath) do
	cc.FileUtils:getInstance():addSearchPath(v)
end

APP_STATE = {STATE_BACKGROUND = 0, STATE_FOREGROUND = 1}

appState = APP_STATE.STATE_FOREGROUND

GAME_SETTING = {
HAS_SAVE = "saved",
ENABLE_MUSIC = "enable_music",
ENABLE_SFX = "enable_sfx",
ENABLE_DUB = "enable_dub"
}

GAME_SOUND = {
title_day = "sound/title_day.mp3",
title_night = "sound/title_night.mp3"
}

local debug_value = 100

if device.platform == "android" then
	CSDKShell = require("sdk.SDKHelper")
	debug_value = CSDKShell.getGameDebugFlag() or 100
	print("config.lua get debug flag is " .. debug_value)
elseif device.platform == "ios" then
	CSDKShell = require("sdk.CSDKShell")
	--debug_value = 100;
	--debug_value = tonumber(debugFileContent) or 100
	--print("not android:config.lua get debug flag is" .. debug_value)
else
	CSDKShell = require("sdk.CSDKShell")
	--dump(debugFileContent)
	--dump("debugFileContent")
	--debug_value = tonumber(debugFileContent) or 100
end

if debug_value ~= 100 then
	LOG_DEBUG = true
end

if debug_value == 101 then
	DEV_BUILD = true
	VERSION_CHECK_DEBUG = true
elseif debug_value == 102 then
	VERSION_CHECK_DEBUG = true
elseif debug_value == 103 then
	YUN_BUILD = true
	VERSION_CHECK_DEBUG = true
end

GameAudio = require("utility.GameAudio")

SDKTKData = require("sdk.SDKTkData")