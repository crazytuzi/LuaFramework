--Filename:	NotificationUtil.lua
--Author:	chengliang
--Date:		2013/12/17
--Purpose:	通知的相关方法

module ("NotificationUtil", package.seeall)

require "script/utils/TimeUtil"
require "script/utils/NotificationDef"

local kNotificationIsExist = "notification_is_exist"

------------ 吃烧鸡 -----------------
local kChickenEnergy_key_noon 		= NotificationDef.kChickenTab.ChickenEnergyNoon			-- 中午吃鸡腿
local kChickenEnergy_key_evening 	= NotificationDef.kChickenTab.ChickenEnergyEvening		-- 晚上吃鸡腿
local kChickenEnergy_key_night 		= NotificationDef.kChickenTab.ChickenEnergyNight 		-- 夜宵吃烧鸡

local chickenEnergy_body			= GetLocalizeStringBy("key_1577") 	-- 通知文本

-- if(BTUtil:isAppStore() == true ) then
-- 	chickenEnergy_body = GetLocalizeStringBy("key_2580")
-- end


-- 中午吃鸡腿
function addChickenEnergyNotification_noon()
	-- add by yangrui
	if not isCanOpenNoti(kChickenEnergy_key_noon) then
		return
	end
	chickenEnergyNotification_noon()
end

--[[
	@des 	: 开启中午吃鸡腿
	@param 	: 
	@return : 
--]]
function chickenEnergyNotification_noon( ... )
    local noonTimeInterval = TimeUtil.getDevIntervalByTime(115900) 	
	local curTimeInterval = TimeUtil.getSvrTimeByOffset()
	local fireTimeInterval = 0
	if(curTimeInterval>noonTimeInterval)then
	 	fireTimeInterval = noonTimeInterval + 3600 * 24
	else
		fireTimeInterval = noonTimeInterval
	end
	NotificationManager:addLocalNotificationBy(kChickenEnergy_key_noon, chickenEnergy_body, fireTimeInterval, kCFCalendarUnitDay_BT)
end

-- 晚上吃鸡腿
function addChickenEnergyNotification_evening()
	-- add by yangrui
	if not isCanOpenNoti(kChickenEnergy_key_evening) then
		return
	end
	chickenEnergyNotification_evening()
end

--[[
	@des 	: 开启晚上吃鸡腿
	@param 	: 
	@return : 
--]]
function chickenEnergyNotification_evening( ... )
    local eveningTimeInterval = TimeUtil.getDevIntervalByTime(175900) 	
	local curTimeInterval = TimeUtil.getSvrTimeByOffset()
	local fireTimeInterval = 0
	if(curTimeInterval>eveningTimeInterval)then
	 	fireTimeInterval = eveningTimeInterval + 3600 * 24
	else
		fireTimeInterval = eveningTimeInterval
	end
	NotificationManager:addLocalNotificationBy(kChickenEnergy_key_evening, chickenEnergy_body, fireTimeInterval, kCFCalendarUnitDay_BT)
end

--夜宵烧鸡
function addChickenEnergyNotification_night()
	-- add by yangrui
	if not isCanOpenNoti(kChickenEnergy_key_night) then
		return
	end
	chickenEnergyNotification_night()
end

--[[
	@des 	: 开启夜宵烧鸡
	@param 	: 
	@return : 
--]]
function chickenEnergyNotification_night( ... )
	local nightTimeInterval = TimeUtil.getDevIntervalByTime(205900) 	
	local curTimeInterval = TimeUtil.getSvrTimeByOffset()
	local fireTimeInterval = 0
	if(curTimeInterval>nightTimeInterval)then
	 	fireTimeInterval = nightTimeInterval + 3600 * 24
	else
		fireTimeInterval = nightTimeInterval
	end
	NotificationManager:addLocalNotificationBy(kChickenEnergy_key_night, chickenEnergy_body, fireTimeInterval, kCFCalendarUnitDay_BT)
end

--------------------------- 体力回复满 -------------------------
local kEnergyRestoreFull_key = NotificationDef.kEnergyRestoreTab.EnergyRestoreFull 			-- 体力回复满
local energy_restore_full_body = GetLocalizeStringBy("key_2454")

-- 体力恢复满通知
function addRestoreEnergyNotification()
	-- add by yangrui
	if not isCanOpenNoti(kEnergyRestoreFull_key) then
		return
	end
	restoreEnergyNotification()
end

--[[
	@des 	: 开启体力恢复满通知
	@param 	: 
	@return : 
--]]
function restoreEnergyNotification( ... )
	local rest_time = UserModel.getEnergyFullTime()
	if(rest_time <= 0)then
		-- 取消 通知
		NotificationManager:cancelLocalNotificationBy(kEnergyRestoreFull_key)
	else
		local fireTimeInterval = BTUtil:getSvrTimeInterval()+rest_time
		NotificationManager:addLocalNotificationBy(kEnergyRestoreFull_key, energy_restore_full_body, fireTimeInterval, 0)
	end
end


------------------------- 长时间未登录通知 --------------------
local kLongTimeNoSee_key = NotificationDef.kLongTimeTab.LongTimeNoSee
local body_longTimeNoSee = GetLocalizeStringBy("key_2599")

-- 长时间未登录通知
function addLongTimeNoSeeNotification()
	-- add by yangrui
	if not isCanOpenNoti(kLongTimeNoSee_key) then
		return
	end
	longTimeNoSeeNotification()
end

--[[
	@des 	: 开启长时间未登录通知
	@param 	: 
	@return : 
--]]
function longTimeNoSeeNotification( ... )
	local longTime = 3600*24*3
	local fireTimeInterval = BTUtil:getSvrTimeInterval()+longTime
	NotificationManager:addLocalNotificationBy(kLongTimeNoSee_key, body_longTimeNoSee, fireTimeInterval, kCFCalendarUnitDay_BT)
end


------------------------- 世界boss开始通知 ----------------------
local kWorldBossStart_key = NotificationDef.kWorldBossTab.StartWorldBoss
local body_worldBossStart = GetLocalizeStringBy("key_1555")

-- 世界boss开始通知
function addWorldBossStartNotification()
	-- add by yangrui
	if not isCanOpenNoti(kWorldBossStart_key) then
		return
	end
	worldBossStartNotification()
end

--[[
	@des 	: 开启世界boss开始通知
	@param 	: 
	@return : 
--]]
function worldBossStartNotification( ... )
	require "db/DB_Worldboss"
	require "script/ui/boss/BossData"
	local startTimeInterval = TimeUtil.getSvrIntervalByTime(DB_Worldboss.getDataById(1).dayBeginTime+BossData.getBossTimeOffset()) 	
	local curTimeInterval = TimeUtil.getSvrTimeByOffset()
	local fireTimeInterval = 0
	if(curTimeInterval>=startTimeInterval)then
	 	fireTimeInterval = startTimeInterval + 3600 * 24
	else
		fireTimeInterval = startTimeInterval
	end
	NotificationManager:addLocalNotificationBy(kWorldBossStart_key, body_worldBossStart, fireTimeInterval, kCFCalendarUnitDay_BT)
end

-------------------------- 城池资源战报名推送 ---------------------
local kCityResourcesWarSign_key = NotificationDef.kCityTab.CityResWarSign
local body_cityResourcesWarSign = GetLocalizeStringBy("key_2742")

-- 城池资源战报名推送
function addCityResourcesWarSignNotification()
	-- add by yangrui
	if not isCanOpenNoti(kCityResourcesWarSign_key) then
		return
	end
	cityResourcesWarSignNotification()
end

--[[
	@des 	: 开启城池资源战报名推送
	@param 	: 
	@return : 
--]]
function cityResourcesWarSignNotification( ... )
	require "script/ui/guild/city/CityData"
	local timesInfo = CityData.getTimeTable()
	if( not table.isEmpty(timesInfo) and timesInfo.signupStart )then
		local fireTimeInterval = tonumber(timesInfo.signupStart) - 60
		if(fireTimeInterval <= BTUtil:getSvrTimeInterval())then
			fireTimeInterval = fireTimeInterval + 86400 * 7
		end
		NotificationManager:addLocalNotificationBy(kCityResourcesWarSign_key, body_cityResourcesWarSign, fireTimeInterval, kCFCalendarUnitWeek_BT)
	end
end

-------------------------- 城池资源战进入战场推送 ---------------------
local kCityResourcesWarEnter_key = NotificationDef.kCityTab.CityResWarEnter
local body_cityResourcesWarEnter = GetLocalizeStringBy("key_2113")

-- 城池资源战进入战场推送
function addCityResourcesWarEnterNotification()
	-- add by yangrui
	if not isCanOpenNoti(kCityResourcesWarEnter_key) then
		return
	end
	cityResourcesWarEnterNotification()
end

--[[
	@des 	: 开启城池资源战进入战场推送
	@param 	: 
	@return : 
--]]
function cityResourcesWarEnterNotification( ... )
	require "script/ui/guild/city/CityData"
	local timesInfo = CityData.getTimeTable()
	if( not table.isEmpty(timesInfo) and not table.isEmpty(timesInfo.arrAttack) and timesInfo.arrAttack[1][1]  )then
		local fireTimeInterval = tonumber(timesInfo.arrAttack[1][1]) - 60
		if(fireTimeInterval <= BTUtil:getSvrTimeInterval())then
			fireTimeInterval = fireTimeInterval + 86400 * 7
		end
		NotificationManager:addLocalNotificationBy(kCityResourcesWarEnter_key, body_cityResourcesWarEnter, fireTimeInterval, kCFCalendarUnitWeek_BT)
	end
end

-------------------------- 擂台赛推送 ---------------------
local kOlympicRegister_key = NotificationDef.kOlympicTab.OlympicReg
local kOlympicFour_key     = NotificationDef.kOlympicTab.OlympicFour
local kOlympicChampion     = NotificationDef.kOlympicTab.OlympicChampion
--擂台赛报名推送
function addOlympicRegisterNotification()
	-- add by yangrui
	if not isCanOpenNoti(kOlympicRegister_key) then
		return
	end
	olympicRegisterNotification()
end

--[[
	@des 	: 开启擂台赛报名推送
	@param 	: 
	@return : 
--]]
function olympicRegisterNotification( ... )
	require "script/ui/olympic/OlympicData"
	local fireTimeInterval =OlympicData.getOlympicOpenTime() - 180
	NotificationManager:addLocalNotificationBy(kOlympicRegister_key, GetLocalizeStringBy("lcy_50042"), fireTimeInterval, kCFCalendarUnitWeek_BT)
end

--擂台赛4强推送
function addOlympicFourNotification()
	-- add by yangrui
	if not isCanOpenNoti(kOlympicFour_key) then
		return
	end
	olympicFourNotification()
end

--[[
	@des 	: 开启擂台赛4强推送
	@param 	: 
	@return : 
--]]
function olympicFourNotification( ... )
	require "script/ui/olympic/OlympicData"
	local fireTimeInterval =OlympicData.getOlympicOpenTime() + 420
	NotificationManager:addLocalNotificationBy(kOlympicFour_key, GetLocalizeStringBy("lcy_50043"), fireTimeInterval, kCFCalendarUnitWeek_BT)
end

--擂台赛冠军推送
function addOlympicChampionNotification()
	-- add by yangrui
	if not isCanOpenNoti(kOlympicChampion) then
		return
	end
	olympicChampionNotification()
end

--[[
	@des 	: 开启擂台赛冠军推送
	@param 	: 
	@return : 
--]]
function olympicChampionNotification( ... )
	require "script/ui/olympic/OlympicData"
	local fireTimeInterval =OlympicData.getOlympicOpenTime() + 900
	NotificationManager:addLocalNotificationBy(kOlympicChampion, GetLocalizeStringBy("lcy_50044"), fireTimeInterval, kCFCalendarUnitWeek_BT)
end



-- 1)	跨服赛开始报名，推送：
function addKufuNotification( ... )
	-- add by yangrui
	if not isCanOpenNoti(NotificationDef.kLordWarTab.Register) then
		return
	end
	kufuNotification()
end

--[[
	@des 	: 开启跨服赛相关通知
	@param 	: 
	@return : 
--]]
function kufuNotification( ... )
	require "script/ui/lordWar/LordWarData"
	local pushContent = {}
	pushContent[NotificationDef.kLordWarTab.Register]      = { des ="1.跨服赛开始报名，推送："         ,content =GetLocalizeStringBy("lcy_50080")}
	pushContent[NotificationDef.kLordWarTab.InnerAudition] = { des ="2.服内海选赛开始，推送："    		,content =GetLocalizeStringBy("lcy_50081")}
	pushContent[NotificationDef.kLordWarTab.Inner32To16]   = { des ="3.服内16强晋级赛开始，推送："     ,content =GetLocalizeStringBy("lcy_50082")}
	pushContent[NotificationDef.kLordWarTab.Inner16To8]    = { des ="4.服内8强晋级赛开始，推送："      ,content =GetLocalizeStringBy("lcy_50083")}
	pushContent[NotificationDef.kLordWarTab.Inner8To4]     = { des ="5.服内4强晋级赛开始，推送："      ,content =GetLocalizeStringBy("lcy_50084")}
	pushContent[NotificationDef.kLordWarTab.Inner4To2]     = { des ="6.服内半决赛开始，推送："         ,content =GetLocalizeStringBy("lcy_50085")}
	pushContent[NotificationDef.kLordWarTab.Inner2To1]     = { des ="7.服内决赛开始，推送："           ,content =GetLocalizeStringBy("lcy_50086")}
	pushContent[NotificationDef.kLordWarTab.CrossAudition] = { des ="9.跨服海选赛开始，推送："     		,content =GetLocalizeStringBy("lcy_50087")}
	pushContent[NotificationDef.kLordWarTab.Cross32To16]   = { des ="10.跨服16强晋级赛开始，推送：" 	,content =GetLocalizeStringBy("lcy_50088")}
	pushContent[NotificationDef.kLordWarTab.Cross16To8]    = { des ="11.跨服8强晋级赛开始，推送："  	,content =GetLocalizeStringBy("lcy_50089")}
	pushContent[NotificationDef.kLordWarTab.Cross8To4]     = { des ="12.跨服4强晋级赛开始，推送："  	,content =GetLocalizeStringBy("lcy_50090")}
	pushContent[NotificationDef.kLordWarTab.Cross4To2]     = { des ="13.跨服半决赛开始，推送："        ,content =GetLocalizeStringBy("lcy_50091")}
	pushContent[NotificationDef.kLordWarTab.Cross2To1]     = { des ="14.跨服决赛开始，推送："      	,content =GetLocalizeStringBy("lcy_50092")}
	
	--服内冠军
	pushContent[NotificationDef.kLordWarTab.InnerWinner]  = { des ="8)	服内产生冠军，推送：",content = GetLocalizeStringBy("lcy_50095")}
	--跨服冠军
	pushContent[NotificationDef.kLordWarTab.CrossWinner]  = { des ="15)	跨服产生冠军，推送：",content = GetLocalizeStringBy("lcy_50096")}
	
	for k,v in pairs(pushContent) do
		if k == NotificationDef.kLordWarTab.InnerWinner or k == NotificationDef.kLordWarTab.CrossWinner then

		else
			local numStr = string.gsub(k,"kufu_","")
			local step = tonumber(numStr)
			local fireTimeInterval = LordWarData.getRoundStartTime(step) + math.random()%20
			NotificationManager:addLocalNotificationBy(k, 
				v.content, 
				fireTimeInterval, 
				kCFCalendarUnitEra_BT)
		end
	end
	
	--服内冠军
	local fireTimeInterval = LordWarData.getRoundStartTime(LordWarData.kInner2To1) + LordWarData.getOneTurnIntervalTime()*5 + math.random()%20
		NotificationManager:addLocalNotificationBy(NotificationDef.kLordWarTab.InnerWinner, 
			pushContent[NotificationDef.kLordWarTab.InnerWinner].content, 
			fireTimeInterval, 
			kCFCalendarUnitEra_BT)
	--跨服冠军
	local fireTimeInterval = LordWarData.getRoundStartTime(LordWarData.kCross2To1) + LordWarData.getOneTurnIntervalTime()*5 + math.random()%20
		NotificationManager:addLocalNotificationBy(NotificationDef.kLordWarTab.CrossWinner, 
			pushContent[NotificationDef.kLordWarTab.CrossWinner].content, 
			fireTimeInterval, 
			kCFCalendarUnitEra_BT)
end

--[[
	@des 	: 是否关闭该通知 add by yangrui
	@param 	: 
	@return : 
--]]
function isCanOpenNoti( pKey )
	local canContinue = true
	local platformName = BTUtil:getPlatform()
	if( platformName ~= kBT_PLATFORM_WP8 ) then
		-- iOS & Android平台
		local isSupport = isSupportPackage()
		if isSupport then
			-- 底包支持
			local isAllow = PlatformUtil:isAllowNotification()
			-- 初始化
			initUserDefault(pKey)
			local isOpen = CCUserDefault:sharedUserDefault():getBoolForKey(pKey)
			if isAllow then
				if( not isOpen )then
					canContinue = false
				end
			end
		else
			-- 底包不支持
		end
	else
		-- WP平台
	end

	return canContinue
end

--[[
	@des 	: 底包是否支持
	@param 	: 
	@return : 
--]]
function isSupportPackage( ... )
	local result = false
	if PlatformUtil.isAllowNotification ~= nil then
		result = true
	end
	return result
end

--[[
	@des 	: init  UserDefault中 Notification key state
	@param 	: 
	@return : 
--]]
function initUserDefault( pKey )
	local isExist = CCUserDefault:sharedUserDefault():getBoolForKey(kNotificationIsExist)
	if( not isExist )then
		CCUserDefault:sharedUserDefault():setBoolForKey(kNotificationIsExist,true)
		-- init
		CCUserDefault:sharedUserDefault():setBoolForKey(pKey,true)
        CCUserDefault:sharedUserDefault():flush()
	end
end

