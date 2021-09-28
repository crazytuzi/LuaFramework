--[[
文件名:CacheActivity.lua
描述：活动数据抽象类型
创建人：liaoyuangang
创建时间：2016.05.09
--]]

--- 限时活动数据说明
--[[
-- 单个活动数据为：
    {
        ActivityId:Int32 限时活动id
        Name:String限时活动名称
        ExtraInfo:
    }
]]

require("activity.ActivityConfig")

local CacheActivity = class("CacheActivity", {})

function CacheActivity:ctor()
	-- 限时活动服务器原始数据
	self.mActivityInfo = {}
	-- 以限时活动模块Id为key的数据列表
	self.mModuleSubList = {}
	-- 以活动Id为key的数据列表
	self.mIdList = {}
	-- 所有活动列表
	self.mActivityList = {}

	-- 新开活动列表
	self.mNewActivityList = {}
end

function CacheActivity:reset()
	self.mActivityInfo = {}

	self.mModuleSubList = {}

	self.mIdList = {}
	self.mActivityList = {}
	self.mNewActivityList = {}
end

-- 刷新活动信息辅助缓存，主要用于数据获取时效率优化
function CacheActivity:refreshAssistCache()
	self.mModuleSubList = {}
	self.mIdList = {}
	self.mActivityList = {}

	for moduleStr, item in pairs(self.mActivityInfo) do
        local moduleSub = tonumber(moduleStr)
        self.mModuleSubList[moduleSub] = item

        for _, instance in pairs(item) do
        	self.mIdList[instance.ActivityId] = instance
        	table.insert(self.mActivityList, instance)
        end
    end
end

--- 更新限时活动缓存数据
function CacheActivity:setActivityInfo(activityInfo)
    --dump(activityInfo, "activityInfo AAAAAAAAA:")
    self.mActivityInfo = activityInfo
    self:refreshAssistCache()

    self:refreshNewActivity()
end

--- 获取所有限时活动信息
--[[
-- 参数：
    needModuleId: 是否需要模块Id作为key，默认为false
    needClone：是否需要克隆数据，默认为false
-- 返回值：
 ]]
function CacheActivity:getActivityInfo(needModuleId, needClone)
    if needModuleId then
    	return needClone and clone(self.mModuleSubList) or self.mModuleSubList
    else
    	return needClone and clone(self.mActivityList) or self.mActivityList
    end
end

--- 获取某类限时活动的数据
--[[
-- 参数
    moduleSub: 模块Id，在 EnumsConfig.lua文件中定义的ModuleSub枚举值
    needClone: 是否需要克隆数据，默认为false
 ]]
function CacheActivity:getActivityItem(moduleSub, needClone)
    local ret = self.mModuleSubList[moduleSub]
    return needClone and clone(ret) or ret
end

-- 判断是否有某种主活动
--[[
-- 参数
    mainModuleSub： 活动主模块Id，取值为： ModuleSub.eTimedActivity、eCommonHoliday、eChristmasActivity
]]
function CacheActivity:haveMainActivity(mainModuleSub)
    local tempList = ActivityConfig[mainModuleSub]
    if not tempList or not next(tempList) then
        return false
    end
    for key, _ in pairs(tempList) do
        if self.mModuleSubList[key] then
            return true
        end
    end
    return false
end


-- 判断是否有某种主活动的新活动(限时活动\通用活动\节日活动)
--[[
-- 参数
    mainModuleSub： 活动主模块Id，取值为： ModuleSub.eTimedActivity、eCommonHoliday、eChristmasActivity
]]
function CacheActivity:haveMainNewActivity(mainModuleSub)
    local tempList = ActivityConfig[mainModuleSub]
    if not tempList or not next(tempList) then
        return false
    end
    for key, value in pairs(self.mNewActivityList) do
        if value and tempList[key] then
            return true
        end
    end
    return false
end

--- 某限时活动是否为新开的限时活动
--[[
-- 参数
    moduleSub：限时活动的模块Id：翻倍活动（10086）、 单笔充值（eTimedChargeSingle）
                宝库抽奖（eTimedLuckDraw）、累计充值天数（eChargeDays）、累计充值（eTimedChargeTotal）、
                累计消费（eTimedUseTotal）、限时招募（eTimedRecruit）、限时兑换（eTimedExchange）
 ]]
function CacheActivity:activityIsNew(moduleSub)
    return self.mNewActivityList[moduleSub]
end

--- 刷新新开限时活动中的条目
function CacheActivity:refreshNewActivity()
	-- 当前的时间
	local tempTimeTick = Player:getCurrentTime()

    -- 需要排出的列表
    local excludeModule = {
        [ModuleSub.eTimedBossDrop] = true,  -- "福利多多-好友BOSS特殊掉落"
        [ModuleSub.eExtraActivityDinner] = true, -- "体力便当页面"
    }

    local tempTimeInfo = LocalData:getNewTimedActivity()  -- 新开限时活动列表

    if MqTime.isSameDay(tempTimeTick, tempTimeInfo.timeTick) then
        tempTimeInfo.timedActivity = tempTimeInfo.timedActivity or {}
        tempTimeInfo.newTimedActivity = tempTimeInfo.newTimedActivity or {}
        -- 先删除已关闭了的活动信息
        for key, value in pairs(tempTimeInfo.timedActivity) do
            if not self.mModuleSubList[key] or excludeModule[key] then
                tempTimeInfo.timedActivity[key] = nil
                tempTimeInfo.newTimedActivity[key] = nil
            end
        end
        -- 添加新开的活动信息
        for key, value in pairs(self.mModuleSubList or {}) do
            if not tempTimeInfo.timedActivity[key] and not excludeModule[key] then
                tempTimeInfo.timedActivity[key] = true
                tempTimeInfo.newTimedActivity[key] = true
            end
        end
    else
        tempTimeInfo.timedActivity = {}
        tempTimeInfo.newTimedActivity = {}
        for key, value in pairs(self.mModuleSubList or {}) do
            if not excludeModule[key] then
                tempTimeInfo.timedActivity[key] = true
                tempTimeInfo.newTimedActivity[key] = true
            end
        end
    end
    tempTimeInfo.timeTick = tempTimeTick
    self.mNewActivityList = tempTimeInfo.newTimedActivity
    --
    LocalData:saveNewTimedActivity(tempTimeInfo)
    -- 
    for _, moduleId in pairs(ActivityConfig.MainActivity) do
        Notification:postNotification(EventsName.eNewPrefix .. tostring(moduleId))
    end
end

--- 去除新开限时活动中的条目
--[[
-- 参数
    moduleSub：限时活动的模块Id：翻倍活动（10086）、 单笔充值（eTimedChargeSingle）
                宝库抽奖（eTimedLuckDraw）、累计充值天数（eChargeDays）、累计充值（eTimedChargeTotal）、
                累计消费（eTimedUseTotal）、限时招募（eTimedRecruit）、限时兑换（eTimedExchange）
 ]]
function CacheActivity:deleteNewActivity(moduleSub)
    if self:activityIsNew(moduleSub) then
        self.mNewActivityList[moduleSub] = nil

        -- 通知新开限时活动信息改变
        local tempTimeInfo = LocalData:getNewTimedActivity()  -- 新开限时活动列表
        tempTimeInfo.newTimedActivity = self.mNewActivityList
        LocalData:saveNewTimedActivity(tempTimeInfo)

        local mainModule = ActivityConfig.getMainModuleSub(moduleSub)
        Notification:postNotification(EventsName.eNewPrefix .. tostring(mainModule))
        if mainModule ~= moduleSub then
            Notification:postNotification(EventsName.eNewPrefix .. tostring(moduleSub))
        end
    end
end

return CacheActivity