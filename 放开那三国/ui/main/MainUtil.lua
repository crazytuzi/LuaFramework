-- Filename：	MainUtil.lua
-- Author：		chengliang
-- Date：		2015-1-16
-- Purpose：		主界面工具类

module("MainUtil" , package.seeall)

require "script/model/utils/ActivityConfigUtil"

-- 背景图片
function getMainBgName()
	local fileName = "images/main/main_bg.jpg"
	if(ActivityConfigUtil.isActivityOpen("frontShow"))then
		local main_info = ActivityConfigUtil.getDataByKey("frontShow")
		if( (not table.isEmpty(main_info)) )then
			fileName = "images/main/" .. main_info.data[1].main_scene
		end
	end
	return fileName
end

-- 背景特效
function getMainEffectName()
	-- local fileName = "images/base/effect/main/niao"
	local fileName = "images/base/effect/main/zhuchengtx/zhuchengtx"
	if(ActivityConfigUtil.isActivityOpen("frontShow"))then
		local main_info = ActivityConfigUtil.getDataByKey("frontShow")
		if( (not table.isEmpty(main_info)))then
			fileName = "images/base/effect/main/activity/" .. string.gsub(main_info.data[1].main_effect, "\r", "")
		end
	end
	return fileName
end

-- 背景图片2
function getMainBgName2()
	local fileName = nil
	if(ActivityConfigUtil.isActivityOpen("frontShow"))then
		local main_info = ActivityConfigUtil.getDataByKey("frontShow")
		if( (not table.isEmpty(main_info)) )then
			if( main_info.data[1].main_png ~= nil and main_info.data[1].main_png ~= "")then
				fileName = "images/main/" .. main_info.data[1].main_png
			end
		end
	end
	return fileName
end

-- 背景特效2
function getMainEffectName2()
	local fileName = nil
	if(ActivityConfigUtil.isActivityOpen("frontShow"))then
		local main_info = ActivityConfigUtil.getDataByKey("frontShow")
		if( (not table.isEmpty(main_info)) )then
			if( main_info.data[1].main_effect2 ~= nil and main_info.data[1].main_effect2 ~= "")then
				fileName = "images/base/effect/main/activity/" .. string.gsub(main_info.data[1].main_effect2, "\r", "")
			end
		end
	end
	return fileName
end