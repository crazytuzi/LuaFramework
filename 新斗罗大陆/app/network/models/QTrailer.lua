
--
-- Author: Kumo.Wang
-- 新功能预告数据管理
--

local QBaseModel = import("...models.QBaseModel")
local QTrailer = class("QTrailer", QBaseModel)

local QUIViewController = import("...ui.QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QActorProp = import("...models.QActorProp")

QTrailer.EVENT_UPDATE = "QTRAILER.EVENT_UPDATE"

QTrailer.EVENT_TASK_UPDATE = "QTRAILER.EVENT_TASK_UPDATE"
QTrailer.EVENT_TASK_UPDATE_BY_DIALOG = "QTRAILER.EVENT_TASK_UPDATE_BY_DIALOG"

function QTrailer:ctor()
    QTrailer.super.ctor(self)
end

function QTrailer:init()
    self._dispatchTBl = {}
    
    self._trailDic = {} -- key: id
    self._taskTypeConfig = {}
end

function QTrailer:loginEnd(callback)
    self:userLevelGoalGetInfoRequest(true, callback, callback)
    self:_initTaskConfig()
end

function QTrailer:disappear()
    QTrailer.super.disappear(self)
    self:_removeEvent()
end

function QTrailer:_addEvent()
    self:_removeEvent()
end

function QTrailer:_removeEvent()
end

--打开界面
function QTrailer:openDialog(callback)
end

--------------数据储存.KUMOFLAG.--------------

function QTrailer:updateData(data)
    for _, task in ipairs(data) do
        local id = tostring(task.id)
        if not self._trailDic[id] then
            self._trailDic[id] = {}
        end
        for key, value in pairs(task) do
            if key == "taskProgress" then
                local taskStrList = string.split(value, ";")
                for _, taskStr in ipairs(taskStrList) do
                    local taskInfoList = string.split(taskStr, "^")
                    self._trailDic[id][tostring(taskInfoList[1])] = tonumber(taskInfoList[2])
                end
            else
                self._trailDic[id][key] = value
            end
        end
    end
    QPrintTable(self._trailDic)
    self:dispatchEvent({name = QTrailer.EVENT_UPDATE})
end

function QTrailer:getTaskDataByTaskId(taskId)
    for _, dic in pairs(self._trailDic) do
        if dic[tostring(taskId)] then
            return dic
        end
    end
    
    return nil
end

function QTrailer:getTaskProgressByTaskId(taskId)
    for _, dic in pairs(self._trailDic) do
        if dic[tostring(taskId)] then
            return dic[tostring(taskId)] -- number
        end
    end
    
    return 0
end

function QTrailer:isDoneByConfigId(configId)
    local configId = tostring(configId)
    if self._trailDic[configId] then
        return self._trailDic[configId].isReward
    end

    return false
end

--------------调用素材.KUMOFLAG.--------------

--------------便民工具.KUMOFLAG.--------------

function QTrailer:checkRedTips()
    local configList = self:getConfigListByLevel(remote.user.level)
    for _, config in ipairs(configList) do
        local isComplete = false
        local isDone = self:isDoneByConfigId(config.id)
        if isDone then
            isComplete = true
        else
            if config.unlock_task then
                -- 解鎖型任務
                isComplete = app.unlock:checkLock(config.unlock_task)
            elseif config.tasks then
                -- 多任務列表
                local taskDetailData = string.split(config.tasks, ";")
                for _, taskId in ipairs(taskDetailData) do
                    local progress = self:getTaskProgressByTaskId(taskId)
                    local config = self:getTaskConfigByTaskId(taskId)
                    if progress >= tonumber(config.num) then
                        isComplete = true
                    else
                        isComplete = false
                        break
                    end
                end
            else
                isComplete = false
            end
        end
        if isComplete and not isDone then
            return true
        end
    end

    return false
end

function QTrailer:getConfigListByLevel(level, goalType)
    local goalType = goalType or LEVEL_GOAL.MAIN_MENU
    local level = level or 9999

    local configs = QStaticDatabase:sharedDatabase():getLevelGuideInfosByType(goalType)
    local returnList = {}
    for _, config in pairs(configs) do
        if config.show_in == 1 and level >= config.closing_condition then
            table.insert(returnList, config)
        end
    end

    return returnList
end

function QTrailer:getGoalConfigByTaskId(taskId, goalType)
    local goalType = goalType or LEVEL_GOAL.MAIN_MENU

    local configs = QStaticDatabase:sharedDatabase():getLevelGuideInfosByType(goalType)
    for _, config in pairs(configs) do
        if config.tasks then
            local tbl = string.split(config.tasks, ";")
            for _, id in ipairs(tbl) do
                if tostring(taskId) == tostring(id) then
                    return config
                end
            end
        end
    end
    
    return nil
end

function QTrailer:getTaskConfigByTaskId(taskId)
    return QStaticDatabase:sharedDatabase():getTaskById(taskId)
end

function QTrailer:getShortcutById(id)
    return QStaticDatabase:sharedDatabase():getShortcutByID(id)
end

--------------数据处理.KUMOFLAG.--------------

function QTrailer:responseHandler( response, successFunc, failFunc )
    -- QPrintTable( response )
    if (response.api == "USER_LEVEL_GOAL_COMLETE" or response.api == "USER_LEVEL_GOAL_GET_INFO") and response.error == "NO_ERROR" then
        table.insert(self._dispatchTBl, {name = QTrailer.EVENT_UPDATE})
    end

    if successFunc then 
        successFunc(response) 
        self:_dispatchAll()
        return
    end

    if failFunc then 
        failFunc(response)
    end

    self:_dispatchAll()
end

function QTrailer:pushHandler( data )
    -- QPrintTable(data)
end

-- USER_LEVEL_GOAL_GET_INFO                    = 9792;                     // 拉取新功能预告信息 levelGoalGetInfoRequest userLevelGoals
-- USER_LEVEL_GOAL_COMLETE                     = 9793;                     // 领取任务奖励 UserLevelGoalComleteRequest

-- optional bool getAll = 1;//是否获取全部数据  登录时给true，其他给false
function QTrailer:userLevelGoalGetInfoRequest(getAll, success, fail, status)
    local levelGoalGetInfoRequest = {getAll = getAll}
    local request = { api = "USER_LEVEL_GOAL_GET_INFO", levelGoalGetInfoRequest = levelGoalGetInfoRequest}
    app:getClient():requestPackageHandler("USER_LEVEL_GOAL_GET_INFO", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional int32 id = 1; //要领取的奖励的量表id
function QTrailer:userLevelGoalComleteRequest(id, success, fail, status)
    local userLevelGoalComleteRequest = {id = id}
    local request = { api = "USER_LEVEL_GOAL_COMLETE", userLevelGoalComleteRequest = userLevelGoalComleteRequest}
    app:getClient():requestPackageHandler("USER_LEVEL_GOAL_COMLETE", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
        app.tip:floatTip("网络异常，请稍后再试")
        self:userLevelGoalGetInfoRequest(true)
    end)
end

--------------本地工具.KUMOFLAG.--------------

function QTrailer:_dispatchAll()
    if not self._dispatchTBl or table.nums(self._dispatchTBl) == 0 then return end
    local tbl = {}
    for _, eventTbl in pairs(self._dispatchTBl) do
        if not tbl[eventTbl.name] or table.nums(eventTbl) > 1 then
            QPrintTable(eventTbl)
            self:dispatchEvent(eventTbl)
            tbl[eventTbl.name] = true
        end
    end
    self._dispatchTBl = {}
end

-- app.taskEvent:updateTaskEventProgress(app.taskEvent.ACTIVITY_CARNIVAL_PRIZE_EVENT, 1)
-- app.taskEvent:updateTaskEventProgress(app.taskEvent.ARENA_TASK_EVENT, 1, false, isWin)
-- app.taskEvent:updateTaskEventProgress(app.taskEvent.ARCHAEOLOGY_ACTIVE_EVENT, 1, false, false, {compareNum = id})
function QTrailer:_initTaskConfig()
    --[[
        任务id和事件类型的映射 
        param: eventType QTaskEvent 中已经有的事件类型
        param: needWin 战斗类的事件是否需要判断输赢
        param: needCompare 状态类的时间是否需要比较特殊参数中的数据大小。minNum最小值，maxNum最大值。判断条件成立为，不比最小值小，不比最大值大
    ]]--
    self._taskTypeConfig = {
        [app.taskEvent.ACTIVITY_CARNIVAL_PRIZE_EVENT] = { taskId = "4000001" },
        [app.taskEvent.ACTIVITY_CARNIVAL_SCORE_EVENT] = { taskId = "4000002" },
        [app.taskEvent.ARENA_WORSHIP_EVENT] = { taskId = "4000003" },
        [app.taskEvent.ARENA_TASK_EVENT] = { taskId = "4000004", needWin = true },
        [app.taskEvent.ARENA_BUY_FIGHT_COUNT_EVENT] = { taskId = "4000005" },
        [app.taskEvent.ARCHAEOLOGY_ACTIVE_EVENT] = { taskId = "4000006", needCompare = true, minNum = 1005 },
        [app.taskEvent.SOULTRIAL_ACTIVE_EVENT] = { taskId = "4000007", needCompare = true, minNum = 3 },
        [app.taskEvent.TIMEMACHINE_TASK_EVENT] = { taskId = "4000008", needWin = true },
        [app.taskEvent.THUNDER_STORE_BUY_TASK_EVENT] = { taskId = "4000009" },
        [app.taskEvent.THUNDER_ACTIVE_EVENT] = { taskId = "4000010", needCompare = true, minNum = 1 },
        [app.taskEvent.THUNDER_RESET_COUNT_EVENT] = { taskId = "4000011" },
        [app.taskEvent.UNION_STATE_EVENT] = { taskId = "4000012" },
        [app.taskEvent.UNION_SACRIFICE_COUNT_EVENT] = { taskId = "4000013" },
        [app.taskEvent.UNION_SACRIFICE_REWARD_COUNT_EVENT] = { taskId = "4000014" },
        [app.taskEvent.WELFARE_DUNGEON_REWARD_COUNT_EVENT] = { taskId = "4000015" },
        [app.taskEvent.WELFARE_DUNGEON_TASK_EVENT] = { taskId = "4000016" },
        [app.taskEvent.INVATION_SHARE_BOSS_EVENT] = { taskId = "4000017" },
        [app.taskEvent.INVATION_REWARD_COUNT_EVENT] = { taskId = "4000018" },
        [app.taskEvent.INVATION_EVENT] = { taskId = "4000019" },
        [app.taskEvent.SUN_WAR_REWARD_COUNT_EVENT] = { taskId = "4000020" },
        [app.taskEvent.SUN_WAR_TASK_EVENT] = { taskId = "4000021" },
        [app.taskEvent.SUN_WAR_ACTIVE_EVENT] = { taskId = "4000022", needCompare = true, minNum = 18 },
        [app.taskEvent.SILVERMINE_ASSIST_EVENT] = { taskId = "4000023" },
        [app.taskEvent.SILVERMINE_OCCUPY_EVENT] = { taskId = "4000024" },
        [app.taskEvent.SILVERMINE_HELP_EVENT] = { taskId = "4000025" },
        [app.taskEvent.WORLD_BOSS_TASK_EVENT] = { taskId = "4000026" },
        [app.taskEvent.WORLD_BOSS_AWARD_COUNT_EVENT] = { taskId = "4000027" },
        [app.taskEvent.GLORY_ARENA_TASK_EVENT] = { taskId = "4000028", needWin = true },
        [app.taskEvent.GLORY_ARENA_CLASS_UP_EVENT] = { taskId = "4000029" },
        [app.taskEvent.GLORY_ARENA_CLASS_AWARD_COUNT_EVENT] = { taskId = "4000030" },
        [app.taskEvent.METALCITY_STORE_BUY_TASK_EVENT] = { taskId = "4000031" },
        [app.taskEvent.METAILCITY_EVENT] = { taskId = "4000032", needWin = true },
        [app.taskEvent.METAILCIT_BUY_FIGHT_COUNT_EVENT] = { taskId = "4000033" },
        [app.taskEvent.SPAR_STORE_BUY_TASK_EVENT] = { taskId = "4000034" },
        [app.taskEvent.FIGHT_CLUB_TASK_EVENT] = { taskId = "4000035", needWin = true },
        [app.taskEvent.FIGHT_CLUB_CLASS_UP_EVENT] = { taskId = "4000036" },
        [app.taskEvent.BLACKROCK_STORE_BUY_TASK_EVENT] = { taskId = "4000037" },
        [app.taskEvent.BLACKROCK_PASS_EVENT] = { taskId = "4000038" },
        [app.taskEvent.BLACKROCK_PASS_WITHOUT_REWARD_EVENT] = { taskId = "4000039" },
        [app.taskEvent.STORM_ARENA_WORSHIP_EVENT] = { taskId = "4000040" },
        [app.taskEvent.STORM_ARENA_SET_DEFENCE_EVENT] = { taskId = "4000041" },
        [app.taskEvent.STORM_ARENA_TASK_EVENT] = { taskId = "4000042" },
        [app.taskEvent.SANCTUARY_STORE_BUY_TASK_EVENT] = { taskId = "4000043" },
        [app.taskEvent.SANCTUARY_BET_COUNT_EVENT] = { taskId = "4000044" },
        [app.taskEvent.SANCTUARY_TASK_EVENT] = { taskId = "4000045" },
        [app.taskEvent.MARITIME_JOIN_ESCORT_EVENT] = { taskId = "4000046" },
        [app.taskEvent.MARITIME_SHIP_START_EVENT] = { taskId = "4000047" },
        [app.taskEvent.MARITIME_TASK_EVENT] = { taskId = "4000048", needWin = true },
        [app.taskEvent.SOTO_TEAM_TASK_EVENT] = { taskId = "4000049", needWin = true },
        [app.taskEvent.SOTO_TEAM_REWARD_COUNT_EVENT] = { taskId = "4000050" },
        [app.taskEvent.MONOPOLY_REFINE_MEDICINE_SUCCESS_EVENT] = { taskId = "4000051" },
        [app.taskEvent.MONOPOLY_PLANT_SUCCESS_EVENT] = { taskId = "4000052" },
        [app.taskEvent.MONOPOLY_CHEAT_EVENT] = { taskId = "4000053" },
    }

    self:_registerTaskEvent()
end

function QTrailer:_registerTaskEvent()
    for key, value in pairs(self._taskTypeConfig) do
        app.taskEvent:registerTaskEvent(key, TASK_SYSTEM_TYPE.TRAILER_TASK, handler(self, self._updateTaskProgress))
    end
end

function QTrailer:_unregisterTaskEvent()
    for key, value in pairs(self._taskTypeConfig) do
        app.taskEvent:unregisterTaskEvent(key, TASK_SYSTEM_TYPE.TRAILER_TASK)
    end
end

function QTrailer:_updateTaskProgress(eventType, number, isReplace, isWin, param)
    -- print("QTrailer:_updateTaskProgress() ", eventType)
    if eventType == nil then return end

    local taskTypeConfig = self._taskTypeConfig[eventType]

    if taskTypeConfig.needWin and not isWin then
        return
    end
    
    if taskTypeConfig.needCompare then
        if taskTypeConfig.minNum and (param and tonumber(param.compareNum) or 0) < taskTypeConfig.minNum then
            return
        end
        if taskTypeConfig.maxNum and (param and tonumber(param.compareNum) or 0) > taskTypeConfig.maxNum then
            return
        end
    end

    local addNum = number or 1
    local taskId = taskTypeConfig.taskId
    -- print("QTrailer:_updateTaskProgress(taskId, addNum) : ", taskId, addNum)
    local taskData = self:getTaskDataByTaskId(taskId)
    if taskData then
        taskData[taskId] = taskData[taskId] + addNum
        self:dispatchEvent({name = QTrailer.EVENT_TASK_UPDATE})
    else
        local config = self:getGoalConfigByTaskId(taskId)
        if config then
            local id = tostring(config.id)
            if not self._trailDic[id] then
                self._trailDic[id] = {}
            end
            self._trailDic[id][taskId] = addNum
            self:dispatchEvent({name = QTrailer.EVENT_TASK_UPDATE})
        else
            print("QTrailer:_updateTaskProgress() not find config ", taskId)
        end
    end

end

function QTrailer:updateTaskProgressByTaskId(taskId, addNum)
    -- 前端不計算，拿後端數據
end

return QTrailer
