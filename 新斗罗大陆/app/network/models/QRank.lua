-- @Author: xurui
-- @Date:   2019-08-29 14:29:22
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-11-27 15:43:22
local QRank = class("QRank")

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNotificationCenter = import("...controllers.QNotificationCenter")

QRank.EVENT_UPDATE_RANK_DIALOG = "EVENT_UPDATE_RANK_DIALOG"
QRank.EVENT_UPDATE_RANK_RECORD = "EVENT_UPDATE_RANK_RECORD"

function QRank:ctor(options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._awardConfigDict = {}      --排行榜奖励列表
	self._awardRecordDict = {}      --排行榜奖励历史记录信息
end

function QRank:init()
	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_USER_TEAM_UP, self._teamUpEvent, self)
end

function QRank:loginEnd(callback)
	if self:checkAwardIsOpen() then
		self:requestRankAwardInfo(true, nil, callback, callback)
	else
		if callback then
			callback()
		end
	end
end

function QRank:disappear()
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_USER_TEAM_UP, self._teamUpEvent, self)
end

function QRank:_teamUpEvent(event)
	local oldLevel = event.oldLevel
	local newLevel = event.newLevel
	local unlockLevel = app.unlock:getConfigByKey("UNLOCK_BENFUJINDU").team_level

	if oldLevel < unlockLevel and newLevel >= unlockLevel then
		self:requestRankAwardInfo(true)
	end
end

function QRank:getRankAwardsConfig()
	if q.isEmpty(self._awardConfigDict) then
		local config = QStaticDatabase:sharedDatabase():getStaticByName("server_rank_rewards")
		for _, value in pairs(config) do
			if self._awardConfigDict[value.task_type] == nil then
				self._awardConfigDict[value.task_type] = {}
			end
			table.insert(self._awardConfigDict[value.task_type], value)
		end
	end

	return self._awardConfigDict
end

function QRank:getRankAwardsByType(rankType)
	local awardConfig = self:getRankAwardsConfig()

	return awardConfig[rankType]
end

function QRank:checkAwardIsOpen()
	if app.unlock:checkLock("UNLOCK_BENFUJINDU") then
		return true
	end

	return false
end

function QRank:checkAwardTips()
	if self:checkAwardIsOpen() == false then return false end

	local awardTip = false
	local awardConfig = self:getRankAwardsConfig()
	for rankType, value in pairs(awardConfig) do
		awardTip = self:checkAwardTipByType(rankType)
		if awardTip then
			break
		end
	end
	return awardTip
end

function QRank:checkAwardTipByType(rankType)
	if self:checkAwardIsOpen() == false then return false end

	local awardTip = false
	local awardConfig = self:getRankAwardsConfig()
	awardConfig = awardConfig[rankType] or {}
	if q.isEmpty(awardConfig) == false and awardConfig[1].unlock then
		if app.unlock:checkLock(awardConfig[1].unlock) == false then
			return false
		end
	end

	for _, value in pairs(awardConfig) do
		local record = self:getRecordById(value.index)
		if record.completeUsersInfo and record.isReward ~= true then
			awardTip = true
			break
		end
	end

	return awardTip
end

function QRank:getRecordById(id)
	if id == nil then return {} end

	local record = self._awardRecordDict[id] or {}
	return record
end

function QRank:updateSeverRecordInfo(data)
	self._awardRecordDict = {}

	for _, value in pairs(data) do
		self._awardRecordDict[value.index] = value
	end
	
	self:updateEvent(QRank.EVENT_UPDATE_RANK_RECORD)
end

function QRank:serverSendRankAwardInfo(data)
	if q.isEmpty(data) then return end

	self._awardRecordDict[data.index] = data

	self:updateEvent(QRank.EVENT_UPDATE_RANK_RECORD)
end

function QRank:updateEvent(event)
	if event then
		self:dispatchEvent({name = event})
	end
end
 
--------------------- request ----------------------

function QRank:responseHandler(request, success, fail, succeeded)
	if request.serverGoalGetMainInfoResponse then
		self:updateSeverRecordInfo(request.serverGoalGetMainInfoResponse.serverGoalUserInfos)
	end

	if succeeded then
		if success then
			success(request)
		end
	else
		if fail then
			fail(request)
		end
	end
end

--[[
	--获取本服任务进度的某个排行榜的数据 
	optional int32 taskType = 1;
]]
function QRank:requestRankAwardInfo(isGetAll, taskType, success, fail, status)
	local serverGoalGetMainInfoRequest = {taskType = taskType, isGetAll = isGetAll}
    local request = {api = "SERVER_GOAL_GET_MAIN_INFO", serverGoalGetMainInfoRequest = serverGoalGetMainInfoRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--[[
	--获取本服任务进度的某个排行榜奖励的top5玩家
	optional int32 index = 1;
]]
function QRank:requestRankTop5Record(index, success, fail, status)
	local serverGoalGetTaskInfoRequest = {index = index}
    local request = {api = "SERVER_GOAL_GET_TASK_INFO", serverGoalGetTaskInfoRequest = serverGoalGetTaskInfoRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--[[
	--获取本服任务进度的某个排行榜的数据 
	repeated int32 index = 1;
]]
function QRank:requestRankAwardIsComplete(index, success, fail, status)
	local serverGoalCompleteRequest = {index = index}
    local request = {api = "SERVER_GOAL_COMPLETE", serverGoalCompleteRequest = serverGoalCompleteRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

return QRank
