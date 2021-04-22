-- @Author: xurui
-- @Date:   2019-05-13 10:12:33
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-27 16:49:09

local QActivityRoundsBaseChild = import(".QActivityRoundsBaseChild")
local QActivitySoulLetter = class("QActivitySoulLetter",QActivityRoundsBaseChild)
local QActivity = import(".QActivity")
local QStaticDatabase = import("..controllers.QStaticDatabase")

QActivitySoulLetter.SOUL_LETTER_MAX_LEVEL = 100     --魂师手札最大等级

QActivitySoulLetter.TAB_AWARD = "TAB_AWARD"
QActivitySoulLetter.TAB_TASK = "TAB_TASK"

QActivitySoulLetter.TYPE_TASK_STATUS_NONE = 0       -- 未完成
QActivitySoulLetter.TYPE_TASK_STATUS_NORMAL = 1     -- 可领取
QActivitySoulLetter.TYPE_TASK_STATUS_DOUBLE = 2     -- 可多倍领取

QActivitySoulLetter.TYPE_TASK_NOT_RECEIVED = 0      -- 未领取
QActivitySoulLetter.TYPE_TASK_RECEIVED = 1          -- 已领取

function QActivitySoulLetter:ctor( ... )
    QActivitySoulLetter.super.ctor(self, ...)

    self._activityInfo = {}   --存放玩家活动信息

    self._weekTaskConfigList = {}   --当前周活动列表
    self._taskProgressDict = {}     --任务完成进度
    self._currentWeekExp = 0        --当前周获得任务经验

    self._normalRecivedAwardIndexDict = {}  --普通奖励已领取id
    self._eliteRecivedAwardIndexDict = {}   --普通奖励已领取id

    --[[
        任务id和事件类型的映射 
        param: eventType QTaskEvent 中已经有的事件类型
        param: needWin 战斗类的事件是否需要判断输赢
    ]]--
    self._taskTypeConfig = {
        [app.taskEvent.ARENA_TASK_EVENT] = { taskType = 1, needWin = true },
        [app.taskEvent.DRAGON_WAR_TASK_EVENT] = { taskType = 2 }, 
        [app.taskEvent.SUN_WAR_TASK_EVENT] = { taskType = 4, needWin = true },
        [app.taskEvent.MONOPOLY_MOVE_EVENT] = { taskType = 5 },
        [app.taskEvent.SILVER_CHEST_BUY_EVENT] = { taskType = 6 }, 
        [app.taskEvent.INVATION_EVENT] = { taskType = 7 },
        [app.taskEvent.METAILCITY_EVENT] = { taskType = 8, needWin = true },
        [app.taskEvent.TOKEN_REDPACKET_EVENT] = { taskType = 9 },
        [app.taskEvent.UNION_QUESTION_EVENT] = { taskType = 10, needWin = true }, 
        [app.taskEvent.SILVERMINE_HELP_EVENT] = { taskType = 11 },
        [app.taskEvent.THUNDER_EVENT] = { taskType = 12, needWin = true }, 
        [app.taskEvent.STORM_ARENA_WORSHIP_EVENT] = { taskType = 13 },
        [app.taskEvent.TKOEN_CONSUME_EVENT] = { taskType = 14 },
        [app.taskEvent.BUY_ENERGY_EVENT] = { taskType = 15 },
        [app.taskEvent.ACTIVE_SKIN_EVENT] = { taskType = 16 },
        [app.taskEvent.TRANSPORT_SUPER_SHIP_TASK_EVENT] = { taskType = 18},
        [app.taskEvent.MALL_BUY_TASK_EVENT] = { taskType = 19 },
        [app.taskEvent.FIGHT_CLUB_TASK_EVENT] = { taskType = 20, needWin = true },
    }

    self:registerTaskEvent()
end

function QActivitySoulLetter:registerTaskEvent()
    for key, value in pairs(self._taskTypeConfig) do
        app.taskEvent:registerTaskEvent(key, TASK_SYSTEM_TYPE.SOUL_LETTER_TASK, handler(self, self._updateTaskProgress))
    end
end

function QActivitySoulLetter:unregisterTaskEvent()
    for key, value in pairs(self._taskTypeConfig) do
        app.taskEvent:unregisterTaskEvent(key, TASK_SYSTEM_TYPE.SOUL_LETTER_TASK)
    end
end

function QActivitySoulLetter:_updateTaskProgress(eventType, num, isReplace, isWin)
    if eventType == nil then return end

    local taskTypeConfig = self._taskTypeConfig[eventType]
    local taskRecord = self:getTaskRecodeByType(taskTypeConfig.taskType)
    if q.isEmpty(taskRecord) == false then
        if isReplace then
            self:setTaskRecodeProcessyType(taskTypeConfig.taskType, num)
        else
            if taskTypeConfig.needWin then
                if isWin then
                    self:setTaskRecodeProcessyType(taskTypeConfig.taskType, taskRecord.process + num)
                end
            else
                self:setTaskRecodeProcessyType(taskTypeConfig.taskType, taskRecord.process + num)
            end
        end
        printTable(self._taskProgressDict[tostring(taskTypeConfig.taskType)])
    end

    self:handleEvent()
end

function QActivitySoulLetter:checkRedTips()
    if self:checkAwardTips() then
        return true
    end

    if self:checkEliteActiveTips() then
        return true
    end

    if self:checkTaskTips() then
        return true
    end

    return false
end

function QActivitySoulLetter:checkAwardTips(tab)
    -- 有奖励领取
    local awards = self:getCanReciveAward(tab)
    if q.isEmpty(awards) == false then
        return true
    end

    return false
end

function QActivitySoulLetter:checkEliteActiveTips( ... )
    --可激活精英
    local eliteUnlock = self:checkEliteUnlock()
    if eliteUnlock == false then
        local activeTip = app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.SOUL_LETER_ACTIVE_ELITE)
        if activeTip then
            return true 
        end 
    end

    return false
end

function QActivitySoulLetter:checkTaskTips()
    if self:checkIsMaxLevel() then
        return false
    end

    --有任务奖励领取
    local weekNum = self:getCurrentWeekNum()
    local maxExpConfig = self:getWeekMaxExp(weekNum)
    local weekExp = self:getWeekExp()
    local tasks = self:getCanReciveTaskAward()
    if weekExp < (maxExpConfig.exp or 0) and q.isEmpty(tasks) == false then
        return true 
    end 
    return false
end

function QActivitySoulLetter:checkActivityComplete()
    return self:checkRedTips()
end

function QActivitySoulLetter:checkIsMaxLevel()
    local activityInfo = self:getActivityInfo()

    local currentLevel = activityInfo.level or 1
    if currentLevel >= QActivitySoulLetter.SOUL_LETTER_MAX_LEVEL then
        return true
    end

    return false
end

function QActivitySoulLetter:checkOpen78Recharge()
    -- if device.platform ~= "ios" then
    --     return true
    -- end

    return true
end

--设置周基金信息
function QActivitySoulLetter:updateActivityInfo(data, isDispatchEvent)
    if data.soulLetterQuestInfoResponse and data.soulLetterQuestInfoResponse.questInfo then
    	local list = data.soulLetterQuestInfoResponse.questInfo.questRecord or {}
        for _, taskRecord in ipairs(list) do
            self._taskProgressDict[tostring(taskRecord.type)] = taskRecord
        end
        if data.soulLetterQuestInfoResponse.questInfo.exp then
            self._currentWeekExp = data.soulLetterQuestInfoResponse.questInfo.exp
        end
	end

    if data.soulLetterGainResponse then
        for key, value in pairs(data.soulLetterGainResponse) do
            self._activityInfo[key] = value
        end
    end

    if data.soulLetterActiveResponse then
        for key, value in pairs(data.soulLetterActiveResponse) do
            self._activityInfo[key] = value
        end
    end

    if data.soulLetterRewardInfoResponse and data.soulLetterRewardInfoResponse.rewardInfo then
        for key, value in pairs(data.soulLetterRewardInfoResponse.rewardInfo) do
            self._activityInfo[key] = value
        end
        if data.soulLetterRewardInfoResponse.buyState then
            self._activityInfo.buyState = data.soulLetterRewardInfoResponse.buyState
        end
    end

    if data.soulLetterQuestCompleteResponse then
        self._activityInfo.level = data.soulLetterQuestCompleteResponse.level
        self._activityInfo.exp = data.soulLetterQuestCompleteResponse.exp
        self._currentWeekExp = data.soulLetterQuestCompleteResponse.questExp
        if data.soulLetterQuestCompleteResponse.quest then
            local list = data.soulLetterQuestCompleteResponse.quest or {}
            for _, taskRecord in ipairs(list) do
                self._taskProgressDict[tostring(taskRecord.type)] = taskRecord
            end
        end
    end

    if self._activityInfo.normalRewardIndexes then
        for _, value in pairs(self._activityInfo.normalRewardIndexes) do
            self._normalRecivedAwardIndexDict[value] = true
        end
    end
    if self._activityInfo.eliteRewardIndexes then
        for _, value in pairs(self._activityInfo.eliteRewardIndexes) do
            self._eliteRecivedAwardIndexDict[value] = true
        end
    end

    if isDispatchEvent ~= false then
        self:handleEvent()
    end
end

--获取周基金信息
--[[
message SoulLetterReward {
    optional int32 type = 1; // 手札类型 @link SoulLetterType
    optional int32 level = 2; // 当前等级
    optional int32 exp = 3; // 当前经验
    repeated int32 normalRewardIndexes = 4; // 已领取的普通奖励
    repeated int32 eliteRewardIndexes = 5; // 已领取的普通奖励
    optional int32 buyState = 4; // 购买状态 1表示88激活 2表示158激活
}
]]
function QActivitySoulLetter:getActivityInfo()
    return self._activityInfo or {}
end

function QActivitySoulLetter:loadActivity()
    if self.isOpen and self:getActivityActiveState() then
        local activities = {}
        local themeInfo = db:getActivityThemeInfoById(QActivity.THEME_ACTIVITY_SOUL_LETTER) or {}
        table.insert(activities, {type = QActivity.TYPE_FORGE, activityId = self.activityId, title = (themeInfo.title or "名匠锻造"), description = "", roundType = "SOUL_LETTER",
        start_at = self.startAt * 1000, end_at = self.endAt * 1000, award_at = self.startAt * 1000, award_end_at = self.endAt * 1000, weight = 14, targets = {}, subject = QActivity.THEME_ACTIVITY_SOUL_LETTER})
        remote.activity:setData(activities)
    else
        remote.activity:removeActivity(self.activityId)
    end
end

function QActivitySoulLetter:getActivityActiveState()
    return true
end

function QActivitySoulLetter:getActivityInfoWhenLogin( success, fail )
    self:requestActivityInfo(false, function(data)
        self:getServerTaskRecord(function ( ... )
            self:loadActivity()
            if success then
                success()
            end
        end)
    end, fail)
end

function QActivitySoulLetter:getServerTaskRecord(callback)
    self:requestSoulLetterTaskInfo(true, function ( ... )
        self:getCurrentWeekTaskDict()
        if callback then
            callback()
        end
    end)
end

function QActivitySoulLetter:activityShowEndCallBack()
    self:handleOffLine()
end

function QActivitySoulLetter:activityEndCallBack()
    self:handleOffLine()
end

function QActivitySoulLetter:handleOnLine()
    if not self.isOpen then
        return
    end

    self:requestActivityInfo(false, function(data)
            self:getServerTaskRecord(function ( ... )
                self:loadActivity()
            end)

        end, fail)
end

function QActivitySoulLetter:handleOffLine()
    -- body
    self._activityInfo = {} 
    
    self._weekTaskConfigList = {}   --当前周活动列表
    self._taskProgressDict = {}     --任务完成进度
    self._currentWeekExp = 0        --当前周获得任务经验

    self._normalRecivedAwardIndexDict = {}  --普通奖励已领取id
    self._eliteRecivedAwardIndexDict = {}   --普通奖励已领取id

    remote.activity:removeActivity(self.activityId, true)
    remote.activity:updateAchievesForList()
    self.isOpen = false

    self:unregisterTaskEvent()

    remote.activityRounds:dispatchEvent({name = remote.activityRounds.SOUL_LETTER_END})
end

function QActivitySoulLetter:handleEvent()
    remote.activityRounds:dispatchEvent({name = remote.activityRounds.SOUL_LETTER_UPDATE, isForce = true})
end

function QActivitySoulLetter:checkNormalAwardStatus(level)
    if level == nil then return false end
    
    if self._normalRecivedAwardIndexDict[level] then
        return true
    end

    return false
end

function QActivitySoulLetter:checkEliteAwardStatus(level)
    if level == nil then return false end
 
    if self._eliteRecivedAwardIndexDict[level] then
        return true
    end

    return false
end

function QActivitySoulLetter:checkEliteUnlock()
    local activityInfo = self:getActivityInfo()
    if activityInfo.type == 4 then
        return true
    end

    return false
end

function QActivitySoulLetter:getCurrentWeekNum()
    local nowTime = q.serverTime()
    local taskRefreshDay = QStaticDatabase:sharedDatabase():getConfigurationValue("BATTLE_PASS_RESET_DAY")
    local weekNum = math.ceil((nowTime - self.startAt) / (taskRefreshDay * DAY))

    return weekNum
end

function QActivitySoulLetter:getTaskList()
    local taskConfigList = self:getCurrentWeekTaskDict()
    local taskList = {}
    for _, value in pairs(taskConfigList) do
        local record, curStep = self:getTaskRecodeByType(value[1].type)
        if q.isEmpty(record) == false then
            local isFind = false
            if curStep then
                local targetStep = curStep.step
                if curStep.status ~= QActivitySoulLetter.TYPE_TASK_STATUS_NONE and curStep.isGet ~= QActivitySoulLetter.TYPE_TASK_NOT_RECEIVED then
                    targetStep = targetStep + 1
                end
                for _, task in ipairs(value) do
                    if task.step == targetStep then
                        isFind = true
                        table.insert(taskList, task)
                        break
                    end
                end
            end
            if isFind == false then
                table.insert(taskList, value[#value])
            end
        else
            table.insert(taskList, value[1])
        end
    end

    return taskList
end

-- 获取任务信息和进行中的阶段信息 若全部完成则返回nil
function QActivitySoulLetter:getTaskRecodeByType(taskType)
    local taskTypeKey = tostring(taskType)
    local record = clone(self._taskProgressDict[taskTypeKey] or {})
    if q.isEmpty(record) == false and taskType == 3 then
        record.process = math.floor((record.process or 0) / 1000 / HOUR)
    end

    local curStepInfo = nil
    if record.step then
        for _, val in ipairs(record.step) do
            curStepInfo = val
            if val.isGet == QActivitySoulLetter.TYPE_TASK_NOT_RECEIVED then
                break
            end
        end
    else
        return record, { step = 1, status = QActivitySoulLetter.TYPE_TASK_STATUS_NONE, isGet = QActivitySoulLetter.TYPE_TASK_NOT_RECEIVED}
    end

    if curStepInfo and curStepInfo.isGet == QActivitySoulLetter.TYPE_TASK_RECEIVED then
        local taskConfig = self:getCurrentWeekTaskDict()
        if not q.isEmpty(taskConfig) and not q.isEmpty(taskConfig[taskTypeKey]) then
            local taskNum = #(taskConfig[taskTypeKey]) or 0
            if #record.step == taskNum then
                curStepInfo = nil
            end
        end
    end

    return record, curStepInfo
end

-- 获取任务
function QActivitySoulLetter:_getTaskGlobalMultiple()
	local multipleTime = db:getConfigurationValue("shouzha_multiple_time") or "6,7"

	multipleTime = string.split(multipleTime, ",")
	local curWday = q.date("*t", q.serverTime()).wday - 1
	if curWday == 0 then
		curWday = 7
	end
	curWday = tostring(curWday)

	if multipleTime then
		for _, val in ipairs(multipleTime) do
			if val == curWday then
				return true
			end
		end
	end
	return false
end

-- 获取任务阶段信息 并且附加是否多倍
function QActivitySoulLetter:getTaskMultipleInfo(info)
    local isMultiple = self:_getTaskGlobalMultiple()
    local progress, curStep = self:getTaskRecodeByType(info.type)
    local curNum = progress.process or 0
    local isComplete = curNum >= (info.num or 0)
	if isComplete then
		-- 若完成没领取则是否双倍参考服务器发来的信息
		if curStep and curStep.isGet == QActivitySoulLetter.TYPE_TASK_NOT_RECEIVED then
			isMultiple = (curStep.status == QActivitySoulLetter.TYPE_TASK_STATUS_DOUBLE)
		end
    end
    return progress, curStep, isMultiple
end


function QActivitySoulLetter:setTaskRecodeProcessyType(taskType, process)
    if self._taskProgressDict[tostring(taskType)] then
        self._taskProgressDict[tostring(taskType)].process = process
    end

    return record
end

function QActivitySoulLetter:checkWeekExpIsFull()
    local weekNum = self:getCurrentWeekNum()
    local maxExpConfig = self:getWeekMaxExp(weekNum)

    return self._currentWeekExp >= maxExpConfig.exp
end

function QActivitySoulLetter:getWeekExp()
    return self._currentWeekExp or 0
end

function QActivitySoulLetter:getCanReciveAward(tab)
    if not tab then
        tab = self.TAB_AWARD
    end

    local awards = {}
    if tab == self.TAB_AWARD then
        local activityInfo = self:getActivityInfo()
        local eliteUnlock = self:checkEliteUnlock()
        local awardConfigDict = self:getAwardsConfig()

        for _, value in ipairs(awardConfigDict) do
            if value.level <= activityInfo.level then
                local normalRecived = self:checkNormalAwardStatus(value.level)
                local eliteRecived = nil 
                if eliteUnlock then
                    eliteRecived = self:checkEliteAwardStatus(value.level)
                end

                if (normalRecived == false and value.normal_reward) or (eliteRecived ~= nil and eliteRecived == false) then
                    table.insert(awards, value.level)
                end
            end
        end
    else
        -- 功能屏蔽，策划不能接受，一次只能领取一层奖励的效果，和后端pk输了，所以，屏蔽这个优化
        -- local eliteUnlock = self:checkEliteUnlock()
        -- if eliteUnlock then
        --     local taskList = self:getTaskList()
        --     for _, info in ipairs(taskList) do
        --         local progress = self:getTaskRecodeByType(info.type)
        --         local curNum = progress.process or 0
        --         local isComplete = curNum >= (info.num or 0)
        --         local isAllComplete = (progress.step or 0) == (info.step or 0)
        --         if isComplete and not isAllComplete then
        --             table.insert(awards, info)
        --         end
        --     end
        -- end
    end

    return awards
end

function QActivitySoulLetter:getCanReciveTaskAward()
    local taskList = self:getTaskList()

    local tasks = {}
    for _, value in pairs(taskList) do
        local record, curStep = self:getTaskRecodeByType(value.type)
        if q.isEmpty(record) == false and record.process >= value.num and curStep then
            table.insert(tasks, value)
        end
    end

    return tasks
end

--获取终极大奖
function QActivitySoulLetter:getFinalAward()
    local finalAward = {}
    local awardConfigs = self:getAwardsConfig()
    for _, value in ipairs(awardConfigs) do
        if value.is_node == 3 and value.rare_reward1 then
            finalAward = value
            break
        end
    end

    return finalAward
end

------------------ static config ------------------------

function QActivitySoulLetter:getTaskConfig()
	local configs = QStaticDatabase:sharedDatabase():getStaticByName("battle_pass_tasks")

	return configs or {}
end

function QActivitySoulLetter:getAwardsConfig()
    if self.rowNum == nil then
        self.rowNum = 1
    end
    local configs = QStaticDatabase:sharedDatabase():getStaticByName("battle_pass_rewards")

    return configs[tostring(self.rowNum)] or {}
end

function QActivitySoulLetter:getRareAwardsConfig()
    print("当前手札轮次----self.rowNum=",self.rowNum)
    local awadsConfigs = self:getAwardsConfig()
    local awardTbl = {}
    for _,v in pairs(awadsConfigs) do
        if v.rare_reward1 and v.show_reward1  then
            table.insert(awardTbl,v.rare_reward1)
        end
        if v.rare_reward2 and v.show_reward2  then
            table.insert(awardTbl,v.rare_reward2)
        end
    end

    return awardTbl
end

function QActivitySoulLetter:getRareAwardsConfigBylevel(level)
    local startLevel = 1

    local awadsConfigs = self:getAwardsConfig()
    local awardTbl = {}
    for _,v in pairs(awadsConfigs) do
        
        if v.level >= startLevel and v.level <= level then
            local eliteRecived = self:checkEliteAwardStatus(v.level)
            if not eliteRecived then
                if v.rare_reward1 and v.show_reward1  then
                    table.insert(awardTbl,v.rare_reward1)
                end
                if v.rare_reward2 and v.show_reward2  then
                    table.insert(awardTbl,v.rare_reward2)
                end
            end
        end
    end

    return awardTbl
end

function QActivitySoulLetter:getWeekMaxExp(week)
    local configs = QStaticDatabase:sharedDatabase():getStaticByName("battle_pass_exp")

    return configs[tostring(week)] or {}
end

function QActivitySoulLetter:getBuyExpConfigByType(expType)
    local configs = QStaticDatabase:sharedDatabase():getStaticByName("battle_pass_buy")

    local data = {}
    for _, value in pairs(configs) do
        if value.buy_type == expType then
            table.insert(data, value)
        end
    end

    return data
end

function QActivitySoulLetter:getCurrentWeekTaskDict()
    local weekNum = self:getCurrentWeekNum()

    if q.isEmpty(self._weekTaskConfigList) or self._currentWeekNum ~= weekNum then
        self._weekTaskConfigList = {}
        local configs = self:getTaskConfig()

        self._currentWeekNum = weekNum
        local configList = {}
        for key, value in pairs(configs) do
            for _, task in pairs(value) do
                if task.week == weekNum then
                    if self._weekTaskConfigList[key] == nil then
                        self._weekTaskConfigList[key] = {}
                    end
                    table.insert(self._weekTaskConfigList[key], task)
                end
            end
        end
    end
    return self._weekTaskConfigList
end

function QActivitySoulLetter:getAwardsConfigByLevel(level)
    local configs = self:getAwardsConfig()

    local config = configs[tonumber(level)]
    if config == nil then
        config = configs[#configs]
    end

    return config or {}
end

-----------------request--------------------------

--奖励信息
function QActivitySoulLetter:requestActivityInfo(isDispatchEvent, success, fail)
    local request = {api = "SOUL_LETTER_REWARD", soulLetterRewardInfoRequest = {}}
    app:getClient():requestPackageHandler(request.api, request, function(data)
            if data then
                self:updateActivityInfo(data, isDispatchEvent)
            end
            if success then
                success()
            end
        end, fail)
end

--精英激活
function QActivitySoulLetter:requestEliteActive(activeId, success, fail)
    local request = {api = "SOUL_LETTER_ACTIVE", soulLetterActiveRequest = {activeId = activeId}}
    app:getClient():requestPackageHandler(request.api, request, function(data)
            if data then
                self:updateActivityInfo(data)
            end
            if success then
                success()
            end
        end, fail)
end
 
--领奖
function QActivitySoulLetter:requestSoulLetterAwards(indexs, success, fail)
    local request = {api = "SOUL_LETTER_GAIN", soulLetterGainRequest = {index = indexs}}
    app:getClient():requestPackageHandler(request.api, request, function(data)
            if data then
                self:updateActivityInfo(data)
            end
            if success then
                success()
            end
        end, fail)
end

--任务列表
function QActivitySoulLetter:requestSoulLetterTaskInfo(isDispatchEvent, success, fail)
    local request = {api = "SOUL_LETTER_QUEST"}
    app:getClient():requestPackageHandler(request.api, request, function(data)
            if data then
                self:updateActivityInfo(data, isDispatchEvent)
            end
            if success then
                success()
            end
        end, fail)
end

--任务完成
function QActivitySoulLetter:requestSoulLetterTaskRecived(questType, isDispatchEvent, success, fail)
    local request = {api = "SOUL_LETTER_QUEST_REWARD", soulLetterQuestCompleteRequest = {questType = questType}}
    app:getClient():requestPackageHandler(request.api, request, function(data)
            if data then
                self:updateActivityInfo(data, isDispatchEvent)
            end
            if success then
                success()
            end
        end, fail)
end

return QActivitySoulLetter
