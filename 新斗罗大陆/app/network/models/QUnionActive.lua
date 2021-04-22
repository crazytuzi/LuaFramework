-- @Author: xurui
-- @Date:   2016-11-09 10:09:57
-- @Last Modified by:   xurui
-- @Last Modified time: 2017-06-12 19:25:31
local QBaseModel = import("...models.QBaseModel")
local QUnionActive = class("QUnionActive", QBaseModel)

local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUnionActive:ctor(options)
	QUnionActive.super.ctor(self)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self.taskType = {
			UNION_SACRIFICE = 20001,             		-- 宗门建设任务
			UNION_INSTANCE = 20002, 			   		-- 宗门副本任务
			DAILY_TASK_POINT = 20003,       			-- 每日任务积分
			ENERGY = 20004,                				-- 体力消耗任务
			SILVER_HELP = 20005,           				-- 魂兽森林援助任务
		}

	self._allActiveTasks = {}      	-- 所有活跃任务
	self._activeTasks = {}      	-- 根据不同类型保存的活跃任务
	self._activeAwards = {}     	-- 活跃宝箱
	self._userActivePoint = 0     	-- 个人活跃积分
	self._activeAwardDoneIds = {}   -- 已领取的活跃宝箱
	self._unionActiveInfo = {}		-- 宗门活跃信息
	self._canTakenChestAward = false  -- 是否可以进行周活跃抽奖  
 
	self.activeTaskRedTip = {}     -- 活跃任务小红点
	self.activeAwardRedTip = false     -- 活跃宝箱小红点
end

function QUnionActive:didappear()
	if remote.user.userConsortia and remote.user.userConsortia.consortiaId and remote.user.userConsortia.consortiaId ~= "" then
		self:updateActiveInfo()
	end
end

function QUnionActive:disappear()
end

function QUnionActive:updateActiveInfo()
	if remote.user.userConsortia == nil or (remote.user.userConsortia.consortiaId == nil or remote.user.userConsortia.consortiaId == "") then
		return 
	end
	self._database = QStaticDatabase:sharedDatabase()

	self:getAllActiveTasks()

	self:requestPersonalActiveInfo(function()
			for _, taskType in pairs(self.taskType) do
				self:setActiveTask(taskType)
			end

			self:setActiveAwards()
		end)

	-- 拉取周活跃信息
	if self:checkUnionWeekChestIsOpen() then
		self:requestGetUnionActiveWeekInfo()
	end
end

-- 按类型处理活跃任务原始数据
function QUnionActive:getAllActiveTasks()
	local tasks = self._database:getTask()
	for _, taskType in pairs(self.taskType) do
		self._allActiveTasks[taskType] = {}
		for _, task in pairs(tasks) do
			if taskType == task.task_type then
				table.insert(self._allActiveTasks[taskType], task)
			end
		end
		table.sort( self._allActiveTasks[taskType], function(a, b) return a.index < b.index end )
	end
end

-- 将后端记录的活跃任务信息放入 self._allActiveTasks 中
function QUnionActive:setPersonalActiveInfo(activeInfo)
	if activeInfo == nil and next(activeInfo) == nil then return end

	local info = activeInfo.consortiaTaskInfo or {}

	for _, taskType in pairs(self.taskType) do
		for _, task in pairs(info) do
			if task.taskType == taskType then
				if self._allActiveTasks[taskType] == nil then
					self._allActiveTasks[taskType] = {}
				end
				self._allActiveTasks[taskType].taskInfo = task
				break
			end
		end
	end
end

function QUnionActive:setUnionActivePoint(point)
	self._userActivePoint = point or 0
end

function QUnionActive:getUnionActivePoint()
	return self._userActivePoint or 0
end

function QUnionActive:setActiveAwardsDoneIds(ids)
	self._activeAwardDoneIds = ids 

	self:setActiveAwards()
end

function QUnionActive:getActiveAwardsDoneIds()
	return self._activeAwardDoneIds or {}
end

function QUnionActive:setCanTakenChestAward(state)
	self._canTakenChestAward = state 
end

function QUnionActive:getCanTakenChestAward()
	return self._canTakenChestAward or false
end

function QUnionActive:setUnionActiveInfo(info)
	self._unionActiveInfo = info
end

function QUnionActive:getUnionActiveInfo()
	return self._unionActiveInfo or {}
end

-- 存放活跃任务宝箱信息
function QUnionActive:setActiveAwards()
	local awards = self._database:getDaliyTaskAwards((remote.user.dailyTeamLevel or 1), 2)
	local currentPoint = self:getUnionActivePoint()

	local ids = self:getActiveAwardsDoneIds()
	local checkDoneFunc = function(id)
		for i = 1, #ids do
			if id == ids[i] then
				return true
			end
		end
		return false
	end

	self.activeAwardRedTip = false
	for i = 1, #awards do
		awards[i].isDone = false
		if checkDoneFunc(awards[i].ID) == true then
			awards[i].isDone = true
		end
		awards[i].isComplete = false
		if awards[i].condition <= currentPoint and awards[i].isDone == false then
			awards[i].isComplete = true
			self.activeAwardRedTip = true
		end
	end
	table.sort( awards, function(a, b)
			return a.condition < b.condition
		end )

	self._activeAwards = awards
end

function QUnionActive:getActiveAwards()
	return self._activeAwards or {}
end

function QUnionActive:setActiveTask(taskType)
	local tasks = self._allActiveTasks[taskType] or {}
	if next(tasks) == nil then return end

	local taskInfo = tasks.taskInfo or {}

	local completeId = taskInfo.completeProgress or nil -- 已完成当前任务类型的任务id
	local curSchedule = taskInfo.progress or 0   -- 当前任务进度

	self.activeTaskRedTip[taskType] = false
	if completeId == nil or completeId == 0 then
		tasks[1].isComplete = false
		if tasks[1].num and tasks[1].num <= curSchedule then
			tasks[1].isComplete = true
			self.activeTaskRedTip[taskType] = true
		end
		self._activeTasks[taskType] = tasks[1]
	else
		for i = 1, #tasks do
			if tasks[i].index == completeId and tasks[i+1] then
				tasks[i+1].isComplete = false
				if tasks[1].num and tasks[i+1].num <= curSchedule then
					tasks[i+1].isComplete = true
					self.activeTaskRedTip[taskType] = true
				end
				self._activeTasks[taskType] = tasks[i+1]
				break
			elseif tasks[i+1] == nil then
				self._activeTasks[taskType] = nil
			end
		end
	end 
	if self._activeTasks[taskType] ~= nil then
		self._activeTasks[taskType].taskInfo = taskInfo
	end
end

-- @param taskType:  当taskType为空时，返回完整task列表
function QUnionActive:getActiveTask(taskType)
	if taskType == nil then return self._activeTasks end
	return self._activeTasks[taskType]
end

function QUnionActive:checkRedTip()
	if self:checkTaskRedTip() then
		return true
	elseif self:checkChestRedTip() then
		return true
	end

	return false
end

function QUnionActive:checkTaskRedTip()

	for _, taskType in pairs(self.taskType) do
		if self.activeTaskRedTip[taskType] == true then
			return true
		end
	end

	if self.activeAwardRedTip then
		return true
	end

	return false
end

function QUnionActive:checkChestRedTip()
	-- 当宝箱抽奖次数为0时, 不显示小红点
	local info = self:getUnionActiveInfo()
	if info.totalDrawMemberCount == nil or info.totalDrawMemberCount < 1 then
		return false
	end
	
	if self:checkUnionWeekChestIsOpen() and self:getCanTakenChestAward() then
		return true
	end

	return false
end

-- 根据任务类型更新任务进度
function QUnionActive:updateActiveTaskProgress(taskType, progress, isUpdate)
	if self._allActiveTasks[taskType] == nil then return end

	if self._allActiveTasks[taskType].taskInfo ~= nil then
		local oldProgress = self._allActiveTasks[taskType].taskInfo.progress or 0
		if isUpdate then
			self._allActiveTasks[taskType].taskInfo.progress = progress
		else
			self._allActiveTasks[taskType].taskInfo.progress = oldProgress + progress
		end
	end

	self:setActiveTask(taskType)
	self:setActiveAwards()
end

-- 根据任务类型更新完成的任务ID
function QUnionActive:updateActiveTaskCompleteId(taskType, id)
	if self._allActiveTasks[taskType] == nil then return end

	if self._allActiveTasks[taskType].taskInfo ~= nil then
		self._allActiveTasks[taskType].taskInfo.completeProgress = id
	end

	self:setActiveTask(taskType)
	self:setActiveAwards()
end

function QUnionActive:checkUnionWeekChestIsOpen()
	local isUnlock = false
	local lockTime = 0
	local nowTime = q.serverTime()
	local currentTime = q.date("*t", nowTime)
	if currentTime.wday == 2 and currentTime.hour >= 5 then
		isUnlock = true
		lockTime = q.getTimeForHMS("24", "00", "00")
	end

	return isUnlock, lockTime
end

function QUnionActive:checkEnterUnionTime()
	local enterTime = remote.user.userConsortia.joinAt/1000 or 0
	local nowTime = q.serverTime()
	enterTime = q.date("*t", enterTime)
	nowTime = q.date("*t", nowTime)

	if nowTime.hour >= 5 and enterTime.year == nowTime.year and enterTime.month == nowTime.month and enterTime.day == nowTime.day then
		return true
	end
	return false
end

--------------------------------- 协议 -----------------------------------

function QUnionActive:responseHandler(data, success, fail, succeeded)
	if succeeded == true then
        if success ~= nil then
            success(data)
        end
    else
        if fail ~= nil then
            fail(data)
        end
    end
end

--[[
	拉取个人活跃信息协议请求
]]
function QUnionActive:requestPersonalActiveInfo(success, fail, status)
    local request = {api = "CONSORTIA_GET_DAILY_TASK_INFO"}
    app:getClient():requestPackageHandler("CONSORTIA_GET_DAILY_TASK_INFO", request, function (response)
        self:responsePersonalActiveInfo(response, success, nil, true)
    end, function (response)
        self:responsePersonalActiveInfo(response, nil, fail)
    end)
end

--[[
	拉取个人活跃信息协议返回
]]
function QUnionActive:responsePersonalActiveInfo(data, success, fail, succeeded)
	if data.consortiaGetDailyTaskInfoResponse then
		self:setPersonalActiveInfo(data.consortiaGetDailyTaskInfoResponse)
		self:setUnionActivePoint(data.consortiaGetDailyTaskInfoResponse.dailyActiveness)
		self:setActiveAwardsDoneIds(data.consortiaGetDailyTaskInfoResponse.consortia_daily_task_reward)
		self:setCanTakenChestAward(data.consortiaGetDailyTaskInfoResponse.isAwardQualified)
	end
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	领取个人活跃任务协议请求
]]
function QUnionActive:requestPersonalActiveComplete(taskId, success, fail, status)
	local consortiaDailyTaskCompleteRequest = {taskId = taskId}
    local request = {api = "CONSORTIA_DAILY_TASK_COMPLETE", consortiaDailyTaskCompleteRequest = consortiaDailyTaskCompleteRequest}
    app:getClient():requestPackageHandler("CONSORTIA_DAILY_TASK_COMPLETE", request, function (response)
        self:responsePersonalActiveComplete(response, success, nil, true)
    end, function (response)
        self:responsePersonalActiveComplete(response, nil, fail)
    end)
end

--[[
	领取个人活跃任务协议返回
]]
function QUnionActive:responsePersonalActiveComplete(data, success, fail, succeeded)
	if data.consortiaDailyTaskCompleteResponse then
		self:setUnionActivePoint(data.consortiaDailyTaskCompleteResponse.dailyActiveness)
	end
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	领取个人活跃任务宝箱协议请求
]]
function QUnionActive:requestPersonalActiveChest(boxId, success, fail, status)
	local consortiaTakeDailyTaskRewardRequest = {boxId = boxId}
    local request = {api = "CONSORTIA_TAKE_DAILY_TASK_REWARD", consortiaTakeDailyTaskRewardRequest = consortiaTakeDailyTaskRewardRequest}
    app:getClient():requestPackageHandler("CONSORTIA_TAKE_DAILY_TASK_REWARD", request, function (response)
        self:responsePersonalActiveChest(response, success, nil, true)
    end, function (response)
        self:responsePersonalActiveChest(response, nil, fail)
    end)
end

--[[
	领取个人活跃任务宝箱协议返回
]]
function QUnionActive:responsePersonalActiveChest(data, success, fail, succeeded)
	if data.consortiaTakeDailyTaskRewardResponse then
		self:setActiveAwardsDoneIds(data.consortiaTakeDailyTaskRewardResponse.takenBoxId)
	end
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	宗门活跃信息协议请求
]]
function QUnionActive:requestGetUnionActiveWeekInfo(success, fail, status)
    local request = {api = "CONSORTIA_GET_WEEK_REWARD_INFO"}
    app:getClient():requestPackageHandler("CONSORTIA_GET_WEEK_REWARD_INFO", request, function (response)
        self:responseUnionGetActiveWeekInfo(response, success, nil, true)
    end, function (response)
        self:responseUnionGetActiveWeekInfo(response, nil, fail)
    end)
end

--[[
	宗门活跃信息协议返回
]]
function QUnionActive:responseUnionGetActiveWeekInfo(data, success, fail, succeeded)
	if data.consortiaGetWeekRewardInfoResponse then
		self:setUnionActiveInfo(data.consortiaGetWeekRewardInfoResponse)
	end
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	宗门周活跃抽奖协议请求
]]
function QUnionActive:requestGetUnionActiveWeekAward(success, fail, status)
    local request = {api = "CONSORTIA_TAKE_WEEK_REWARD"}
    app:getClient():requestPackageHandler("CONSORTIA_TAKE_WEEK_REWARD", request, function (response)
        self:responseUnionGetActiveWeekAward(response, success, nil, true)
    end, function (response)
        self:responseUnionGetActiveWeekAward(response, nil, fail)
    end)
end

--[[
	宗门周活跃抽奖协议返回
]]
function QUnionActive:responseUnionGetActiveWeekAward(data, success, fail, succeeded)
	if data.consortiaTakeDailyTaskRewardResponse then
		self:setActiveAwardsDoneIds(data.consortiaTakeDailyTaskRewardResponse.takenBoxId)
	end
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	宗门活跃排行协议请求
	@param kind:  排行榜类型(WORLD_BOSS_USER_HURT:玩家伤害排行,  WORLD_BOSS_CONSORTIA_HURT:宗门伤害排行)
	@param userId:  玩家的userId
]]
function QUnionActive:requestUnionActiveRank(kind, userId, success, fail, status)
	local rankingsRequest = {kind = kind, userId = userId}
	local request = {api = "RANKINGS", rankingsRequest = rankingsRequest}
	app:getClient():requestPackageHandler("RANKINGS", request, function(response)
			self:responseUnionActiveRank(response, success, nil, true, kind)
		end,
		function(response)
			self:responseUnionActiveRank(response, nil, fail, nil, kind)
		end)
end

--[[
	宗门活跃排行协议返回
]]
function QUnionActive:responseUnionActiveRank(data, success, fail, succeeded, kind)
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	宗门活跃排行协议请求
	@param kind:  排行榜类型(WORLD_BOSS_USER_HURT:玩家伤害排行,  WORLD_BOSS_CONSORTIA_HURT:宗门伤害排行)
	@param userId:  玩家的userId
]]
function QUnionActive:requestUnionActiveChestRecorde(success, fail, status)
	local request = {api = "CONSORTIA_GET_DRAW_LOG"}
	app:getClient():requestPackageHandler("CONSORTIA_GET_DRAW_LOG", request, function(response)
			self:responseUnionActiveChestRecorde(response, success, nil, true, kind)
		end,
		function(response)
			self:responseUnionActiveChestRecorde(response, nil, fail, nil, kind)
		end)
end

--[[
	宗门活跃排行协议返回
]]
function QUnionActive:responseUnionActiveChestRecorde(data, success, fail, succeeded, kind)
	if data.consortiaGetDrawLogResponse then

	end
	self:responseHandler(data, success, fail, succeeded)
end

return QUnionActive