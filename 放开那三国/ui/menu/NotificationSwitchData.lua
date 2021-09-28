-- FileName : NotificationSwitchData.lua
-- Author   : YangRui
-- Date     : 2015-12-28
-- Purpose  : 

module("NotificationSwitchData", package.seeall)

require "script/utils/NotificationDef"

ksChickenTag       = 80001  -- 吃烧鸡
ksOlympicTag       = 80002  -- 擂台争霸
ksWorldBossTag     = 80003  -- 进击的魔神
ksCityResourcesTag = 80004  -- 军团抢粮战
ksEnergyRestoreTag = 80005  -- 体力回满
ksLongTimeTag      = 80006  -- 长时间未登录
ksLordWarTag       = 80007  -- 个人跨服赛

local ksOn         = 0  -- 开启状态
local ksOff        = 1  -- 关闭状态

local ksSupportRedirectVersion = "8.0"  -- 支持跳转的最低系统版本

local notificationKey = { 
	[tostring(ksChickenTag)]       = NotificationDef.kChickenTab,
	[tostring(ksOlympicTag)]       = NotificationDef.kOlympicTab,
	[tostring(ksWorldBossTag)]     = NotificationDef.kWorldBossTab,
	[tostring(ksCityResourcesTag)] = NotificationDef.kCityTab,
	[tostring(ksEnergyRestoreTag)] = NotificationDef.kEnergyRestoreTab,
	[tostring(ksLongTimeTag)]      = NotificationDef.kLongTimeTab,
	[tostring(ksLordWarTag)]       = NotificationDef.kLordWarTab,
}

-- 通知key & 名称
local kNotificationArray = {
	{[tostring(ksChickenTag)]       = GetLocalizeStringBy("yr_8002")},
	{[tostring(ksOlympicTag)]       = GetLocalizeStringBy("yr_8003")},
	{[tostring(ksWorldBossTag)]     = GetLocalizeStringBy("yr_8004")},
	{[tostring(ksCityResourcesTag)] = GetLocalizeStringBy("yr_8005")},
	{[tostring(ksEnergyRestoreTag)] = GetLocalizeStringBy("yr_8009")},
	{[tostring(ksLongTimeTag)]      = GetLocalizeStringBy("yr_8010")},
	-- {[tostring(ksLordWarTag)]       = GetLocalizeStringBy("yr_8011")},
}

--[[
	@des 	: 获取通知开关的状态
	@param 	: 
	@return : 
--]]
function getSwStateByTag( pSwitchTag )
	local result = {}
	local isTrueCount = 0
	local isFalseCount = 0
	local ret = ksOff
	local keyTab = notificationKey[tostring(pSwitchTag)]
	for index,key in pairs(keyTab) do
		result[index] = CCUserDefault:sharedUserDefault():getBoolForKey(key)
	end
	for index,state in pairs(result) do
		if state then
			isTrueCount = isTrueCount+1
		else
			isFalseCount = isFalseCount+1
		end
	end
	if isTrueCount > 0 then
		ret = ksOn
	elseif isFalseCount == table.count(result) then
		ret = ksOff
	end
	
	return ret
end

--[[
	@des 	: 获取通知项数组
	@param 	: 
	@return : 
--]]
function getNotificationArray( ... )
	return kNotificationArray
end

--[[
	@des 	: 是否可以直接跳转
	@param 	: 
	@return : 
--]]
function canRedirect( ... )
	local result = false
	local curVersion = NSBundleInfo:getSysVersion()
	if curVersion >= ksSupportRedirectVersion then
		result = true
	end

	return result
end

--[[
	@des 	: 关闭通知
	@param 	: 
	@return : 
--]]
function cancleNotificationByTag( pSwitchTag )
	local keyTab = notificationKey[tostring(pSwitchTag)]
	for index,key in pairs(keyTab) do
		NotificationManager:cancelLocalNotificationBy(key)
		-- 同步UserDefault中的操作
		CCUserDefault:sharedUserDefault():setBoolForKey(key,false)
	end
    CCUserDefault:sharedUserDefault():flush()
end

--[[
	@des 	: 关闭所有通知
	@param 	: 
	@return : 
--]]
function closeAllNotifications( ... )
	NotificationManager:cancelAllLocalNotification()
	-- 同步UserDefault中的操作
	for tag,keyTab in pairs(notificationKey) do
		for index,key in pairs(keyTab) do
			CCUserDefault:sharedUserDefault():setBoolForKey(key,false)
		end
	end
	CCUserDefault:sharedUserDefault():flush()
end

--[[
	@des 	: 打开通知
	@param 	: 
	@return : 
--]]
function addNotificationByTag( pSwitchTag )
	if pSwitchTag == ksChickenTag then
		NotificationUtil.chickenEnergyNotification_noon()
		NotificationUtil.chickenEnergyNotification_evening()
		-- NotificationUtil.chickenEnergyNotification_night()
	elseif pSwitchTag == ksOlympicTag then
		if( DataCache.getSwitchNodeState(ksOlympic,false) )then
			NotificationUtil.olympicRegisterNotification()
			NotificationUtil.olympicFourNotification()
			NotificationUtil.olympicChampionNotification()
		end
	elseif pSwitchTag == ksWorldBossTag then
		NotificationUtil.worldBossStartNotification()
	-- elseif pSwitchTag == ksCityResourcesTag then
	-- 	NotificationUtil.cityResourcesWarSignNotification()
	-- 	NotificationUtil.cityResourcesWarEnterNotification()
	elseif pSwitchTag == ksEnergyRestoreTag then
		NotificationUtil.restoreEnergyNotification()
	elseif pSwitchTag == ksLongTimeTag then
		NotificationUtil.longTimeNoSeeNotification()
	-- elseif pSwitchTag == ksLordWarTag then
	-- 	NotificationUtil.kufuNotification()
	end
	-- 同步UserDefault中的操作
	local keyTab = notificationKey[tostring(pSwitchTag)]
	for index,key in pairs(keyTab) do
		CCUserDefault:sharedUserDefault():setBoolForKey(key,true)
	end
	CCUserDefault:sharedUserDefault():flush()
end
