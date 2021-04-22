--
-- Author: wkwang
-- Date: 2014-11-28 16:03:48
-- 活动副本
--
local QBaseModel = import("..models.QBaseModel")
local QActivityInstance = class("QActivityInstance",QBaseModel)
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QVIPUtil = import("..utils.QVIPUtil")

function QActivityInstance:ctor(options)
	QActivityInstance.super.ctor(self)
	self._activityConfig = {}
end

--初始化配置数据
function QActivityInstance:init()
	self._activityConfig = {}
	self.config = QStaticDatabase:sharedDatabase():getMaps()
	local total = table.nums(self.config)
	for i=1,total,1 do
		local config = self.config[tostring(i)]
		if config ~= nil then
			config.unlock_team_level = tonumber(config.unlock_team_level)
			if config.dungeon_type == DUNGEON_TYPE.ACTIVITY_TIME or config.dungeon_type == DUNGEON_TYPE.ACTIVITY_CHALLENGE then
				table.insert(self._activityConfig, config)
			end
		end
	end
end

--更新活动本信息
function QActivityInstance:updateActivityInfo(info)
	if self._passInfo == nil then self._passInfo = {} end
	info = info or {}
	local isUpdate = false
	for id,value in pairs(info) do
		if self:getDungeonById(value.id) ~= nil then
			self._passInfo[value.id] = value
			isUpdate = true
		end
	end
	return isUpdate
end

--获取关卡通关信息dungeonId
function QActivityInstance:getPassInfoById(dungeonId)
	if self._passInfo == nil then self._passInfo = {} end
	for _,value in pairs(self._passInfo) do
		if value.id == dungeonId then
			return value
		end
	end
	return nil
end

--获取前一个关卡通关信息dungeonId
function QActivityInstance:getPerPassInfoById(dungeonId)
	if self._passInfo == nil then self._passInfo = {} end
	local currConfig = nil
	for _,value in pairs(self._activityConfig) do
		if value.dungeon_id == dungeonId then
			currConfig = value
		end
	end
	if currConfig == nil then return nil end
	local perDungeon = nil
	for _,value in pairs(self._activityConfig) do
		if value.int_dungeon_id == (currConfig.int_dungeon_id - 1) and value.instance_id == currConfig.instance_id then
			perDungeon = value
			break
		end
	end
	if perDungeon == nil then return nil,nil end
	return self._passInfo[perDungeon.dungeon_id],perDungeon
end

--查询dungeonId是否为活动本
function QActivityInstance:checkIsActivityByDungenId(dungeonId)
	for _,value in pairs(self._activityConfig) do
		if value.dungeon_id == dungeonId then
			return true
		end
	end
	return false
end

--获取配置通过instanceId
function QActivityInstance:getInstanceListById(id)
	local list = {}
	for _,value in pairs(self._activityConfig) do
		if value.instance_id == id then
			table.insert(list, value)
		end
	end
	return list
end

--获取配置通过dungeonId
function QActivityInstance:getDungeonById(dungeonId)
	for _,value in pairs(self._activityConfig) do
		if value.dungeon_id == dungeonId then
			return value
		end
	end
	return nil
end

--获取配置通过int_dungeonId
function QActivityInstance:getDungeonByIntId(intDungeonId)
	for _,value in pairs(self._activityConfig) do
		if value.int_dungeon_id == intDungeonId then
			return value
		end
	end
	return nil
end

--获取副本集合名称通过类型
function QActivityInstance:getInstanceGroupNameByType(type)
	local name = ""
	if type == 3 then
		name = "试炼宝屋"
	elseif type == 4 then
		name = "试炼宝屋"		
	end
	return name
end

--获取某类型地图的关卡是否开启
function QActivityInstance:checkIsOpenForInstanceId(instanceId)
	local list = self:getInstanceListById(instanceId)
	if #list > 0 then
		return self:checkIsOpenForDungeonId(list[1].dungeon_id)
	end
	return true
end

--获取某关卡是否开启
function QActivityInstance:checkIsOpenForDungeonId(dungeonId)
	local dungeonConfig = QStaticDatabase:sharedDatabase():getDungeonConfigByID(dungeonId)
	if dungeonConfig.activity_date == nil then
		return true
	end
	local currDate = q.date("*t", (q.serverTime() - 4*60*60))
	local wday = currDate.wday + 6
	if wday > 7 then
		wday = wday - 7
	end
	if string.find(dungeonConfig.activity_date, tostring(wday)) ~= nil then
		return true
	end
	return false
end

--获取指定类型的地图CD时间
function QActivityInstance:checkCDTimeByType(typeName)
	local cdConfig = QStaticDatabase:sharedDatabase():getConfiguration().DUNGEON_ACTIVITIES_CD.value
	local activityLatest = 0
	local instanceName = self:_convertTypeToDungeonType(typeName)
	for index = 1, 9 do
		local passInfo = self:getPassInfoById(instanceName.. index)
		if passInfo ~= nil and (passInfo.lastPassAt or 0) > activityLatest then
			activityLatest = (passInfo.lastPassAt or 0) 
		end
	end
	if math.floor((q.serverTime()*1000 - activityLatest)/1000) >= cdConfig or self:_checkCanNoCD() == true then
		return true
	else 
		return false, cdConfig - math.floor((q.serverTime()*1000 - activityLatest)/1000)
	end
	return true
end

function QActivityInstance:_checkCanNoCD()
	if QVIPUtil:getActivityNoCD() == true then
		return true
	end
	if app.unlock:checkLock("HUODONGBENXIAO_CD") == true then
		return true
	end
	return false
end

function QActivityInstance:_convertTypeToDungeonType(type)
	if type == "activity1_1" then
		return "booty_bay_"
	elseif type == "activity2_1" then
		return "dwarf_cellar_"
	elseif type == "activity3_1" then
		return "strength_test_"
	else
		return "wisdom_test_"
	end
end

function QActivityInstance:getAttackCountByType(instanceId)
	if instanceId == ACTIVITY_DUNGEON_TYPE.TREASURE_BAY then
		return (remote.user.todayActivity1_1Count or 0) - (remote.user.dungeonSeaBuyCount or 0)
	elseif instanceId == ACTIVITY_DUNGEON_TYPE.BLACK_IRON_BAR then
		return (remote.user.todayActivity2_1Count or 0) - (remote.user.dungeonBarBuyCount or 0)
	elseif instanceId == ACTIVITY_DUNGEON_TYPE.STRENGTH_CHALLENGE then
		return (remote.user.todayActivity3_1Count or 0) - (remote.user.dungeonStrengthBuyCount or 0)
	elseif instanceId == ACTIVITY_DUNGEON_TYPE.WISDOM_CHALLENGE then
		return (remote.user.todayActivity4_1Count or 0) - (remote.user.dungeonSapientialBuyCount or 0)
	end
	return 0
end

function QActivityInstance:getAttackMaxCountByType(instanceId)
	local addCount = 0
	if remote.activity:checkMonthCardActive(2) then
		addCount = addCount + 1
	end
	if instanceId == ACTIVITY_DUNGEON_TYPE.TREASURE_BAY then
		return QStaticDatabase:sharedDatabase():getConfiguration().BPPTY_BAY_COUNT.value + addCount
	elseif instanceId == ACTIVITY_DUNGEON_TYPE.BLACK_IRON_BAR then
		return QStaticDatabase:sharedDatabase():getConfiguration().DWARF_CELLAR_COUNT.value + addCount
	elseif instanceId == ACTIVITY_DUNGEON_TYPE.STRENGTH_CHALLENGE then
		return QStaticDatabase:sharedDatabase():getConfiguration().STRENGTH_TRIAL.value
	elseif instanceId == ACTIVITY_DUNGEON_TYPE.WISDOM_CHALLENGE then
		return QStaticDatabase:sharedDatabase():getConfiguration().SAPIENTIAL_TRIAL.value
	end
	return 0
end

--返回已经购买的次数
function QActivityInstance:getBuyCountByType(instanceId)
	if instanceId == ACTIVITY_DUNGEON_TYPE.TREASURE_BAY then
		return remote.user.dungeonSeaBuyCount or 0
	elseif instanceId == ACTIVITY_DUNGEON_TYPE.BLACK_IRON_BAR then
		return remote.user.dungeonBarBuyCount or 0
	elseif instanceId == ACTIVITY_DUNGEON_TYPE.STRENGTH_CHALLENGE then
		return remote.user.dungeonStrengthBuyCount or 0
	elseif instanceId == ACTIVITY_DUNGEON_TYPE.WISDOM_CHALLENGE then
		return remote.user.dungeonSapientialBuyCount or 0
	end
	return 0
end

--返回该VIP级别能购买的最大次数以及最大VIP级别能购买的次数
function QActivityInstance:getMaxBuyCountByType(instanceId)
	if instanceId == ACTIVITY_DUNGEON_TYPE.TREASURE_BAY then
		return QVIPUtil:getSeaMaxCount(), QVIPUtil:getSeaMaxCount(QVIPUtil:getMaxLevel())
	elseif instanceId == ACTIVITY_DUNGEON_TYPE.BLACK_IRON_BAR then
		return QVIPUtil:getBarMaxCount(), QVIPUtil:getBarMaxCount(QVIPUtil:getMaxLevel())
	elseif instanceId == ACTIVITY_DUNGEON_TYPE.STRENGTH_CHALLENGE then
		return QVIPUtil:getStengthMaxCount(), QVIPUtil:getStengthMaxCount(QVIPUtil:getMaxLevel())
	elseif instanceId == ACTIVITY_DUNGEON_TYPE.WISDOM_CHALLENGE then
		return QVIPUtil:getIntellectMaxCount(), QVIPUtil:getIntellectMaxCount(QVIPUtil:getMaxLevel())
	end
	return 0
end

function QActivityInstance:convertTypeToNum(instanceId)
	if instanceId == ACTIVITY_DUNGEON_TYPE.TREASURE_BAY then
		return 1
	elseif instanceId == ACTIVITY_DUNGEON_TYPE.BLACK_IRON_BAR then
		return 2
	elseif instanceId == ACTIVITY_DUNGEON_TYPE.STRENGTH_CHALLENGE then
		return 3
	elseif instanceId == ACTIVITY_DUNGEON_TYPE.WISDOM_CHALLENGE then
		return 4
	end
end

return QActivityInstance