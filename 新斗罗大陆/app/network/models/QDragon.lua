--
-- Author: Kumo.Wang
-- 养龙数据管理
--

local QBaseModel = import("...models.QBaseModel")
local QDragon = class("QDragon", QBaseModel)

local QUIViewController = import("...ui.QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

QDragon.QA = 1 -- 答题
QDragon.TIME = 2 -- 修炼
QDragon.FIGHT = 3 -- 躲避球

QDragon.QA_STATE_UNCOMPLETE = 0 -- 未答题
QDragon.QA_STATE_COMPLETE = 1 -- 已答题

QDragon.NEW_DAY = "QDRAGON_NEW_DAY"
QDragon.TASK_COMPLETE = "QDRAGON_TASK_COMPLETE"
QDragon.TASK_END = "QDRAGON_TASK_END"
QDragon.CHANGE_UPDATE = "QDRAGON_CHANGE_UPDATE" -- 幻化成功
QDragon.TASK_REWARD_SHOW_END = "QDRAGON_TASK_REWARD_SHOW_END"
QDragon.TASK_INFO_UPDATE = "QDRAGON_TASK_INFO_UPDATE"

QDragon.TYPE_WEAPON = 1
QDragon.TYPE_WARRIOR = 2

QDragon.EXP_RESOURCE_ID = 41
QDragon.EXP_RESOURCE_TYPE = ITEM_TYPE.DRAGON_EXP

QDragon.TASK_BASE_EXP = 1 -- 任务球的完成领取时候的基础经验值
QDragon.TASK_FIGHT_TIME = 30 -- 潮汐炼体时间

local DRAGON_COLOR = {"BLUE", "PURPLE", "ORANGE", "RED"}

QDragon.DRAGON_FLOOR = {"Ⅰ","Ⅱ","Ⅲ","Ⅳ","Ⅴ","Ⅵ","Ⅶ","Ⅷ","Ⅸ","Ⅹ"}


function QDragon:ctor()
    QDragon.super.ctor(self)
end

function QDragon:init()
    self._dispatchTBl = {}

    --------------酷猫添加--------------
    self.isSelectedTask = false  -- 是否已经选择过当日的任务
    self.selectTaskId = 0 -- 当前选择的任务Id，如果 isSelectedTask == false，则可以更改
    self.multipleId = 0 -- 选择领奖倍率的id，发领奖请求的时候赋值，任务球展示特效之后制0

    self._taskMaxProgressNumber = 0 -- 周任务的最大进度值
    self._isTaskComplete = false  -- 是否完成，外部不可随意访问修改
    self._isTaskEnd = false -- 是否完结，外部不可随意访问修改
    self._lastConsortiaTask = "" -- 保存最近一次的数据，用作更新对比
    self._lastParam = "" -- 保存最近一次的数据，用作更新对比
    self._lastCurProgressNumberDic = {} -- 保存最近一次的数据

    self._taskConfigList = {} 
    self._taskMultipleConfigList = {}
    self._taskBoxConfigList = {}
    self._taskBoxTargetDic = {} -- key是box对应的target值，value是list的index
    self._taskBoxOpenedDic = {}
    self._myTaskInfo = {}
    self._taskProgressDic = {}
    self._taskQAInfoList = {}
    self._taskQAConfigList = {}

    --------------树哥添加--------------
    self._dragonOldLevel = 0    -- 武魂旧的等级信息
    self._dragonInfo = {}       -- 武魂信息
    self._dragonLog = {}        -- 日志
    self._dragonExp = 0         -- 升级经验
end

function QDragon:didappear()
    self._userEventProxy = cc.EventProxy.new(remote.user)
    self._userEventProxy:addEventListener(remote.user.EVENT_TIME_REFRESH, handler(self, self.refreshTimeHandler))
end

function QDragon:disappear()
    if self._remoteProexy ~= nil then
        self._remoteProexy:removeAllEventListeners()
        self._remoteProexy = nil
    end

    if self._userEventProxy ~= nil then
        self._userEventProxy:removeAllEventListeners()
        self._userEventProxy = nil
    end
end

function QDragon:loginEnd()
    if app.unlock:checkLock("SOCIATY_DRAGON") then
        self:consortiaGetDragonInfoRequest()
    end
end

function QDragon:resetData()
    self._dragonInfo = {}       -- 武魂信息
end

function QDragon:openDialog()
    if app.unlock:checkLock("SOCIATY_DRAGON", true) == false then
        return
    end
    
    self:consortiaGetDragonInfoRequest(function(data)
            local dragonInfo = self:getDragonInfo()
            if dragonInfo and dragonInfo.dragonId == 0 then
                app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnionDragonTrainChange"}, {isPopCurrentDialog = false})
            else
                app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnionDragonTrain"}, {isPopCurrentDialog = true})
            end
        end)
end

function QDragon:openDragonTask()
    self:openDialog()
end

function QDragon:refreshTimeHandler(event)
    if event.time == nil or event.time == 0 then
    end

    if event.time == nil or event.time == 5 then
        self:resetDragonTaskData()
        self:dispatchEvent( { name = QDragon.NEW_DAY } )
        if app.unlock:checkLock("SOCIATY_DRAGON") then
            self:consortiaGetDragonInfoRequest()
        end
    end
end

--------------酷猫添加--------------

function QDragon:getChestImgPath()
    local _, isAllOpened = self:checkTaskBoxRedTips()
    if isAllOpened then
        return "ui/socity_fuben/baoxiang11.png"
    else
        return "ui/socity_fuben/baoxiang12.png"
    end
end

function QDragon:getNumChangeCcbPath(num)
    if num > 0 then
        return "effects/Tips_add.ccbi"
    elseif num < 0 then 
        return "effects/Tips_Decrease.ccbi"
    end
end

function QDragon:resetDragonTaskData()
    self.isSelectedTask = false
    self.selectTaskId = 0
    self.multipleId = 0

    self._isTaskComplete = false
    self._isTaskEnd = false
    self._lastConsortiaTask = ""
    self._lastParam = ""

    self._taskBoxOpenedDic = {}
    self._myTaskInfo = {}
    self._taskProgressDic = {}
    self._taskQAInfoList = {}


    self._dragonInfo.consortiaTask = ""
end

function QDragon:getMyTaskInfo()
    return self._myTaskInfo
end

function QDragon:setTaskCompleteState( boo )
    if not boo or boo == self._isTaskComplete then return end
    self._isTaskComplete = true -- 任务完成不可逆
    self:dispatchEvent( { name = QDragon.TASK_COMPLETE } )
end
function QDragon:getTaskCompleteState()
    return self._isTaskComplete
end

function QDragon:setTaskEndState( boo )
    if not boo or boo == self._isTaskEnd then return end
    self._isTaskEnd = true -- 任务完结不可逆
    self:dispatchEvent( { name = QDragon.TASK_END } )
end
function QDragon:getTaskEndState()
    return self._isTaskEnd
end

function QDragon:getTaskInfoById( taskId )
    if not self._taskConfigList or #self._taskConfigList == 0 then
        local dragonTaskConfig = QStaticDatabase.sharedDatabase():getDragonTaskConfig()
        for _, value in pairs(dragonTaskConfig) do
            value.id = tonumber(value.id)
            value.target = tonumber(value.target)
            self._taskConfigList[value.id] = value
        end
    end
    -- QPrintTable(self._taskConfigList)
    return self._taskConfigList[tonumber(taskId)]
end

function QDragon:getTaskMultipleInfoByIndex( index )
    if not self._taskMultipleConfigList or #self._taskMultipleConfigList == 0 then
        local str = QStaticDatabase.sharedDatabase():getConfigurationValue("sociaty_dragon_multiple")
        local tbl = string.split(str, ";")
        for _, value in ipairs(tbl) do
            local tmpTbl = string.split(value, ",")
            self._taskMultipleConfigList[tonumber(tmpTbl[1])] = {multiple = tonumber(tmpTbl[2]), consume = tonumber(tmpTbl[3])}
        end
    end
    -- QPrintTable(self._taskMultipleConfigList)
    return self._taskMultipleConfigList[tonumber(index)]
end

function QDragon:getTaskExplain()
    return QStaticDatabase.sharedDatabase():getConfigurationValue("sociaty_dragon_task_reward")
end

function QDragon:getTaskCurProgressById( taskId )
    local returnLastCurProgressNumber = self._lastCurProgressNumberDic[taskId]
    if not self._dragonInfo or not self._dragonInfo.consortiaTask or self._dragonInfo.consortiaTask == "" then 
        self._taskProgressDic = {}
        self._lastCurProgressNumberDic[taskId] = 0
        return 0, returnLastCurProgressNumber
    end

    -- QPrintTable(self._dragonInfo)
    if not self._taskProgressDic or not next(self._taskProgressDic) or self._lastConsortiaTask ~= self._dragonInfo.consortiaTask then
        self._lastConsortiaTask = self._dragonInfo.consortiaTask

        -- 任务Id,进度;任务Id,进度;任务Id,进度;
        local str = self._dragonInfo.consortiaTask
        local tbl = string.split(str, ";")
        for _, value in ipairs(tbl) do
            local tmpTbl = string.split(value, ",")
            -- QPrintTable(tmpTbl)
            if tmpTbl and #tmpTbl > 1 then
                self._taskProgressDic[tonumber(tmpTbl[1])] = tonumber(tmpTbl[2])
            end
        end
    end
    -- QPrintTable(self._taskProgressDic)
    local taskCurProgress = self._taskProgressDic[tonumber(taskId)] or 0
    if taskCurProgress > self:getTaskMaxProgressNumber() then
        taskCurProgress = self:getTaskMaxProgressNumber()
    end

    self._lastCurProgressNumberDic[taskId] = taskCurProgress
    return taskCurProgress, returnLastCurProgressNumber
end

function QDragon:getTaskProgressStr()
    return self._dragonInfo.consortiaTask
end


function QDragon:getTaskMinProgress()
    local minProgressNumber = self:getTaskMaxProgressNumber()
    local taskId = 1
    while true do
        local taskInfo = self:getTaskInfoById( taskId )
        if taskInfo then
            local curProgressNumber = self:getTaskCurProgressById( taskId )
            if curProgressNumber < minProgressNumber then
                minProgressNumber = curProgressNumber
            end
            taskId = taskId + 1
        else
            break
        end
    end

    return minProgressNumber
end

function QDragon:getTaskBoxConfigList()
    if not self._taskBoxConfigList or not next(self._taskBoxConfigList) then
        local dragonBoxConfig = QStaticDatabase.sharedDatabase():getDragonBoxConfig()
        for _, value in pairs(dragonBoxConfig) do
            table.insert(self._taskBoxConfigList, value)
        end
        table.sort(self._taskBoxConfigList, function(a, b)
                return tonumber(a.box_id) < tonumber(b.box_id)
            end)

        for index, value in ipairs(self._taskBoxConfigList) do
            self._taskBoxTargetDic[tonumber(value.box_target)] = index
        end
    end
    -- QPrintTable(self._taskBoxConfigList)
    return self._taskBoxConfigList
end

function QDragon:getTaskBoxConfigByTarget( target )
    local target = tonumber(target)
    local index = 0
    if target then
        index = self._taskBoxTargetDic[target]
    end

    if index > 0 then
        return self._taskBoxConfigList[index]
    end
    return nil
end

function QDragon:getTaskBoxOpenedDic( isForce )
    if not self._taskBoxOpenedDic or not next(self._taskBoxOpenedDic) or isForce then
        if self._myTaskInfo and self._myTaskInfo.openedBox then
            for _, boxId in ipairs(self._myTaskInfo.openedBox or {}) do
                self._taskBoxOpenedDic[tonumber(boxId)] = true
            end
        end
    end
    -- QPrintTable(self._taskBoxOpenedDic)
    return self._taskBoxOpenedDic
end

function QDragon:isTaskBoxOpenedByBoxId( boxId )
    local taskBoxOpenedDic = self:getTaskBoxOpenedDic()
    local boxId = tonumber(boxId)
    local isTaskBoxOpened = taskBoxOpenedDic[boxId]
    if not isTaskBoxOpened then
        taskBoxOpenedDic = self:getTaskBoxOpenedDic(true)
        isTaskBoxOpened = taskBoxOpenedDic[boxId]
    end

    return isTaskBoxOpened
end

function QDragon:getTaskMaxProgressNumber()
    if self._taskMaxProgressNumber > 0 then return self._taskMaxProgressNumber end

    local taskBoxConfigList = self:getTaskBoxConfigList()
    for _, value in pairs(taskBoxConfigList) do
        local num = tonumber(value.box_target) or 0
        if num > self._taskMaxProgressNumber then
            self._taskMaxProgressNumber = num
        end
    end
    return self._taskMaxProgressNumber
end

function QDragon:getTaskCompleteRequirementById( taskId )
    local config = self:getTaskInfoById(taskId)
    if config then
        if taskId == self.QA then
            -- 完成条件答题，单位次数
            return config.target
        elseif taskId == self.TIME then
            -- 完成条件持续时间，单位分钟
            return config.target * MIN
        elseif taskId == self.FIGHT then
            -- 完成条件战斗，单位次数
            return config.target * self.TASK_FIGHT_TIME
        end
    end
    return 0
end

function QDragon:updateQAInfoByIndex( index )
    if not index then
        index = (self._myTaskInfo.answerCount or 0) + 1
    end

    if not index or not self._myTaskInfo.param or self._myTaskInfo.param == "" and self.selectTaskId ~= self.QA then return end

    if not self._taskQAInfoList or #self._taskQAInfoList == 0 or self._lastParam ~= self._myTaskInfo.param then
        self._lastParam = self._myTaskInfo.param
        local qIdTbl = string.split(self._myTaskInfo.param, ";")
        for index, qId in ipairs(qIdTbl) do
            self._taskQAInfoList[index] = {qId = tonumber(qId)}
        end
    end
    -- QPrintTable(self._taskQAInfoList)
    return self._taskQAInfoList[tonumber(index)]
end

function QDragon:getQAConfigById( qId )
    if not self._taskQAConfigList or #self._taskQAConfigList == 0 then
        local dragonQuestionConfig = QStaticDatabase.sharedDatabase():getDragonQuestionConfig()
        for _, value in pairs(dragonQuestionConfig) do
            self._taskQAConfigList[tonumber(value.id)] = value
        end
    end
    -- QPrintTable(self._taskQAConfigList)
    return self._taskQAConfigList[tonumber(qId)]
end

function QDragon:updateTimeByStartAt( startAt )
    if not startAt then
        startAt = self._myTaskInfo.trainStartAt
    end

    local timeStr = "--:--:--"
    local isComplete = true
    local isStart = false
    if not startAt or startAt == FOUNDER_TIME or self.selectTaskId ~= self.TIME then return isStart, isComplete, timeStr end

    isStart = true
    local holdTime = self:getTaskCompleteRequirementById(self.TIME)
    local endTime = startAt/1000 + holdTime

    if q.serverTime() >= endTime then
        timeStr = "00:00"
    else
        local sec = endTime - q.serverTime()
        -- if sec >= 30*60 then
        --     color = ccc3(255, 216, 44)
        -- else
        --     color = ccc3(255, 63, 0)
        -- end
        local h, m, s = self:_formatSecTime( sec )
        timeStr = string.format("%02d:%02d", m, s)
        isComplete = false
    end

    return isStart, isComplete, timeStr
end

-- 将秒为单位的数字转换成 00：00：00格式
function QDragon:_formatSecTime( sec )
    local h = math.floor((sec/3600)%24)
    local m = math.floor((sec/60)%60)
    local s = math.floor(sec%60)

    return h, m, s
end

function QDragon:openTaskDialogByTaskId( taskId )
    if not taskId then taskId = self.selectTaskId end

    if taskId == self.QA then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogUnionDragonTrainQA", options = {id = taskId, callBack = function()
                remote.dragon:openTaskRewardDialog()
            end}})
    elseif taskId == self.TIME then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogUnionDragonTrainTime", options = {id = taskId, callBack = function()
                remote.dragon:openTaskRewardDialog()
            end}})
    elseif taskId == self.FIGHT then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogUnionDragonTrainFight", options = {id = taskId, callBack = function()
            end}})
    end
end

function QDragon:openTaskBoxDialog()
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogUnionDragonTrainBox", options = {callBack = function()
        end}})
end

function QDragon:openTaskRewardDialog()
    if self.isSelectedTask and self:getTaskCompleteState() and not self:getTaskEndState() then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogUnionDragonTrainTaskReward", options = {id = self.selectTaskId, callBack = function()
            end}})
    end
end

function QDragon:dispatchTaskRewardShowEndEvent()
    self:dispatchEvent( { name = QDragon.TASK_REWARD_SHOW_END } )
end

function QDragon:getLuckyDrawById( id )
    if not id then return end
    return QStaticDatabase.sharedDatabase():getluckyDrawById( id )
end

function QDragon:showRewardForDialog(prizes)
    local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
        options = {awards = prizes, callback = function()
            self:dispatchTaskRewardShowEndEvent()
        end}},{isPopCurrentDialog = false} )
    dialog:setTitle("恭喜获得武魂回馈奖励")
end

function QDragon:checkTaskBoxRedTips()
    local minProgressNumber = self:getTaskMinProgress()
    local taskBoxConfigList = self:getTaskBoxConfigList()
    local isAllOpened = true
    for _, config in ipairs(taskBoxConfigList) do
        local target = tonumber(config.box_target)
        if not self:isTaskBoxOpenedByBoxId(config.box_id) then
            isAllOpened = false
            if target <= minProgressNumber then
                return true, isAllOpened
            end
        end
    end
    return false, isAllOpened
end

--------------树哥添加--------------
function QDragon:getDragonInfo()
    return self._dragonInfo
end

function QDragon:getDragonLogInfo()
    return self._dragonLog
end

function QDragon:getDragonUpExp()
    return self._dragonExp
end

-- 宗门进入设置
function QDragon:setDragonInfo(dragonInfo)
    self._dragonInfo = dragonInfo
end

function QDragon:getDragonColor(dragonId, level)
    local bigLevel = self:getDragonBigLevel(dragonId, level)
    local color = QIDEA_QUALITY_COLOR[DRAGON_COLOR[bigLevel]]
    return color, bigLevel
end

function QDragon:getDragonBigLevel(dragonId, level)
    local dragonSkills = db:getUnionDragonSkillById(dragonId, level)
    local bigLevel = 0
    for i, skill in pairs(dragonSkills) do
        if level >= skill.dragon_level then
            bigLevel = bigLevel + 1
        end
    end
    return bigLevel
end

function QDragon:checkDragonLevelOpenType(level, oldLevel, callback)
    local dragonInfo = remote.dragon:getDragonInfo()
    local dragonSkill = db:getUnionDragonSkillById(dragonInfo.dragonId)
    local isBigUp = false
    for i, dragon in pairs(dragonSkill) do
        if level == dragon.dragon_level then
            isBigUp = true
            break
        end
    end
    if isBigUp then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogUnionDragonTrainBigLevelSucess",
            options = {callback = callback, level = level, oldLevel = oldLevel}})
    else
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogUnionDragonTrainLevelSucess",
            options = {callback = callback, level = level, oldLevel = oldLevel}})
    end
end

function QDragon:checkLevelRewards()
    local dragonInfo = remote.dragon:getDragonInfo()
    local historyLevelRewards = remote.user.userConsortia.dragon_level_reward_info or {}
    local levels = {}
    local index = 1
    local num = dragonInfo.level or 1
    for i = 2, num do
        local isHave = false
        for _, value in pairs(historyLevelRewards) do
            if value == i then
                isHave = true
            end
        end
        if isHave == false then
            levels[index] = i
            index = index + 1
        end
    end

    return levels
end

function QDragon:checkDragonLevelUp(callback)
    local levels = self:checkLevelRewards()
    if levels and next(levels) then
        -- local dragonLevel = levels[1]
        local startLevel = levels[1] - 1
        local endLevel = levels[#levels]
        local dragonInfo = db:getUnionDragonInfoByLevel(endLevel)
        -- local awards = db:getluckyDrawById(dragonInfo.level_reward)
        self:checkDragonLevelOpenType(endLevel, startLevel, function()
            self:requestUnionDragonUpgradeAwards(nil, function(data)
                local awards = data.prizes or {}
                local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
                    options = {awards = awards--[[, callback = callback]]}},{isPopCurrentDialog = false} )
                dialog:setTitle("恭喜您获得宗门武魂升级奖励")
            end)
        end)
    end
end

function QDragon:checkDragonLevelByAddExp()
    if self._dragonOldLevel ~= self._dragonInfo.level then
        local dragonLevel = self._dragonInfo.level
        local dragonInfo = db:getUnionDragonInfoByLevel(dragonLevel)
        local awards = db:getluckyDrawById(dragonInfo.level_reward)
        self:checkDragonLevelOpenType(dragonLevel, nil, function()
            self:requestUnionDragonUpgradeAwards(dragonLevel, function(data)
                local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
                    options = {awards = awards, callback = callback}},{isPopCurrentDialog = false} )
                dialog:setTitle("恭喜您获得宗门武魂升级奖励")
            end)
        end)
    end
end

function QDragon:isDragonActivate(dragonId)
    local buyedDragonIds = self._dragonInfo.buyedDragonId or {}
    for i, id in ipairs(buyedDragonIds) do
        if dragonId == id then
            return true
        end
    end
    return false
end

function QDragon:getPropInfo(data)
    local prop = {}
    if data == nil or next(data) == nil then return prop end

    if data.attack_value then
        local num, word = q.convertLargerNumber(data.attack_value or 0)
        local info = {}
        info.name = "攻击"
        info.value = math.floor(num)..word
        prop[#prop+1] = info
    end
    if data.hp_value then
        local num, word = q.convertLargerNumber(data.hp_value or 0)
        local info = {}
        info.name = "生命"
        info.value = math.floor(num)..word
        prop[#prop+1] = info
    end
    if data.armor_physical then
        local num, word = q.convertLargerNumber(data.armor_physical or 0)
        local info = {}
        info.name = "物防"
        info.value = math.floor(num)..word
        prop[#prop+1] = info
    end
    if data.armor_magic then
        local num, word = q.convertLargerNumber(data.armor_magic or 0)
        local info = {}
        info.name = "法防"
        info.value = math.floor(num)..word
        prop[#prop+1] = info
    end
    
    return prop
end

function QDragon:checkDragonRedTip()
    if app.unlock:checkLock("SOCIATY_DRAGON", false) == false then
        return false
    end

    if self:checkDragonTaskRedTip() then
        return true
    end

    local levels = self:checkLevelRewards()
    if levels and next(levels) then
        return true
    end
    
    return false
end

function QDragon:checkDragonTaskRedTip()
    if not self._dragonInfo.dragonId or self._dragonInfo.dragonId == 0 then
        return false
    end

    print("QDragon:checkDragonTaskRedTip()", self.isSelectedTask, self:getTaskCompleteState(), self:getTaskEndState())
    if not self.isSelectedTask then
        return true
    elseif self.isSelectedTask and self:getTaskCompleteState() and not self:getTaskEndState() then
        return true
    end
    
    if self:checkTaskBoxRedTips() then
        return true
    end
    
    return false
end
--------------数据处理--------------

function QDragon:responseHandler( response, successFunc, failFunc )
    -- QPrintTable( response )
    if response.consortiaGetDragonInfoResponse and response.error == "NO_ERROR" then
        if response.consortiaGetDragonInfoResponse.consortiaDragon then
            self._dragonInfo = response.consortiaGetDragonInfoResponse.consortiaDragon
        end
        if response.consortiaGetDragonInfoResponse.consortiaDragonLog then
            self._dragonLog = response.consortiaGetDragonInfoResponse.consortiaDragonLog
        end
        
        local dragonExp = response.consortiaGetDragonInfoResponse.dragonExp
        if dragonExp and dragonExp ~= "" then
            local tbl = string.split(dragonExp, "^")
            self._dragonExp = tonumber(tbl[2])
        end

        if response.consortiaGetDragonInfoResponse.myInfo then
            local data = response.consortiaGetDragonInfoResponse.myInfo
            self._myTaskInfo = data
            self.selectTaskId = data.taskId
            self.isSelectedTask = self.selectTaskId > 0
            
            -- 这一段只针对修炼，前后端做双保险，因为时间是一直在变的
            if data.taskId == self.TIME and not data.taskIsComplete and data.trainStartAt then
                local isStart, isComplete = self:updateTimeByStartAt(data.trainStartAt)
                data.taskIsComplete = isStart and isComplete or false
            end
            self:setTaskCompleteState(data.taskIsComplete)
            self:setTaskEndState(data.taskIsAddToConsortia)
        end
        table.insert(self._dispatchTBl, QDragon.TASK_INFO_UPDATE)
    end

    if response.consortia and response.error == "NO_ERROR" then
        -- 宗门武魂升级的时候，如果有返回consortia结构，则更新下consortia数据，主要是用于宗门武魂buff的刷新用
        remote.union:updateDragonTrainBuff(response)
    end

    if response.api == "CONSORTIA_DRAGON_CHANGE_DRAGON" then
        -- self:dispatchEvent( { name = QDragon.CHANGE_UPDATE } )
        table.insert(self._dispatchTBl, QDragon.CHANGE_UPDATE)
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

function QDragon:pushHandler( data )
    -- QPrintTable(data)
end

--[[
    // 公会养龙
    CONSORTIA_GET_DRAGON_INFO                   = 4415;                     // 公会养龙(宗门武魂)--获取公会龙的信息 参考参数 无参数 返回 ConsortiaGetDragonInfoResponse
    CONSORTIA_DRAGON_CHANGE_DRAGON              = 4416;                     // 公会养龙(宗门武魂)--修改武魂Id 武魂幻化  参考参数 ConsortiaDragonChangeDragonIdRequest 返回
    CONSORTIA_DRAGON_CHOOSE_TASK                = 4417;                     // 公会养龙(宗门武魂)--选择今日日任务 参考参数 ConsortiaChooseTaskdRequest 返回
    CONSORTIA_DRAGON_DO_TASK                    = 4418;                     // 公会养龙(宗门武魂)--做任务 参考参数 ConsortiaDragonDoTaskRequest 返回
    CONSORTIA_DRAGON_GET_BOX_PRIZE              = 4419;                     // 公会养龙(宗门武魂)--领取目标奖励 参考参数 ConsortiaDragonGetBoxPrizeRequest 返回
    CONSORTIA_DRAGON_GET_TASK_PROGRESS          = 4420;                     // 公会养龙(宗门武魂)--领取任务进度 参考参数 ConsortiaDragonGetTaskProgressRequest 返回
    CONSORTIA_GET_DRAGON_LEVEL_UP_REWARD        = 4421;                     // 公会养龙(宗门武魂)--领取巨龙升级奖励 参考参数 ConsortiaGetDragonLevelUpRewardRequest 返回 ConsortiaGetDragonLevelUpRewardResponse
    CONSORTIA_GET_CONTRIBUTION_RANKING          = 4422;                     // 公会养龙(宗门武魂)--个人贡献排行信息
    CONSORTIA_BUY_DRAGON                        = 4423;                     // 公会养龙(宗门武魂)--购买武魂 参考参数 ConsortiaBuyDragonRequest
    CONSORTIA_GET_DRAGON_LOG                    = 4404;                     // 公会养龙(宗门武魂)--拉取养龙日志 参考参数 无参数 返回  ConsortiaGetDragonLogResponse
]]

function QDragon:consortiaGetDragonInfoRequest(success, fail, status)
    local request = { api = "CONSORTIA_GET_DRAGON_INFO" }
    app:getClient():requestPackageHandler("CONSORTIA_GET_DRAGON_INFO", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional int32 dragonId                       = 1;                        // 宗门武魂--修改武魂Id(——武魂幻化)
function QDragon:consortiaDragonChangeDragonIdRequest(dragonId, success, fail, status)
    local consortiaDragonChangeDragonIdRequest = {dragonId = dragonId}
    local request = { api = "CONSORTIA_DRAGON_CHANGE_DRAGON", consortiaDragonChangeDragonIdRequest = consortiaDragonChangeDragonIdRequest }
    app:getClient():requestPackageHandler("CONSORTIA_DRAGON_CHANGE_DRAGON", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional int32 dragonId                       = 1;                        // 宗门武魂--购买武魂Id
function QDragon:consortiaBuyDragonRequest(dragonId, success, fail, status)
    local consortiaBuyDragonRequest = {dragonId = dragonId}
    local request = { api = "CONSORTIA_BUY_DRAGON", consortiaBuyDragonRequest = consortiaBuyDragonRequest }
    app:getClient():requestPackageHandler("CONSORTIA_BUY_DRAGON", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional int32 dragonId                       = 1;                        // 宗门武魂--贡献排行
function QDragon:consortiaDragonContributionRequest(success, fail, status)
    local request = { api = "CONSORTIA_GET_CONTRIBUTION_RANKING" }
    app:getClient():requestPackageHandler("CONSORTIA_GET_CONTRIBUTION_RANKING", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--[[
    领取巨龙升级奖励协议请求
    @param: level, 巨龙等级，ps：和后端约定，如果level为0，则领全部玩家当前可以领的奖励
]]
function QDragon:requestUnionDragonUpgradeAwards(level, success, fail, status)
    local consortiaGetDragonLevelUpRewardRequest = {level = level}
    local request = {api = "CONSORTIA_GET_DRAGON_LEVEL_UP_REWARD", consortiaGetDragonLevelUpRewardRequest = consortiaGetDragonLevelUpRewardRequest}
    app:getClient():requestPackageHandler("CONSORTIA_GET_DRAGON_LEVEL_UP_REWARD", request, function(response)
            self:responseHandler(response, success, nil, true, kind)
        end,
        function(response)
            self:responseHandler(response, nil, fail, nil, kind)
        end)
end

--[[
    拉取养龙日志协议请求
]]
function QDragon:consortiaDragonLogrequest(success, fail, status)
    local request = {api = "CONSORTIA_GET_DRAGON_LOG"}
    app:getClient():requestPackageHandler("CONSORTIA_GET_DRAGON_LOG", request, function(response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional int32 taskId                        = 1;                         // 宗门武魂--个人选择今日任务
function QDragon:consortiaChooseTaskdRequest(taskId, success, fail, status)
    local consortiaChooseTaskRequest = {taskId = taskId}
    local request = { api = "CONSORTIA_DRAGON_CHOOSE_TASK", consortiaChooseTaskRequest = consortiaChooseTaskRequest }
    app:getClient():requestPackageHandler("CONSORTIA_DRAGON_CHOOSE_TASK", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional int32 taskId                        = 1;                          // 宗门武魂--任务Id
-- optional string param                         = 2;                         // 宗门武魂--所需参数(鲜草培养给答案Id)
function QDragon:consortiaDragonDoTaskRequest(taskId, param, success, fail, status)
    local consortiaDragonDoTaskRequest = {taskId = taskId, param = param}
    local request = { api = "CONSORTIA_DRAGON_DO_TASK", consortiaDragonDoTaskRequest = consortiaDragonDoTaskRequest }
    app:getClient():requestPackageHandler("CONSORTIA_DRAGON_DO_TASK", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- repeated int32 boxId                        = 1;                         // 宝箱Id
-- optional bool  isSecretary  = 2;                                           // 是否是小秘书
function QDragon:consortiaDragonGetBoxPrizeRequest(boxId, isSecretary, success, fail, status)
    self._dragonOldLevel = self._dragonInfo.level
    local consortiaDragonGetBoxPrizeRequest = {boxId = boxId, isSecretary = isSecretary}
    local request = { api = "CONSORTIA_DRAGON_GET_BOX_PRIZE", consortiaDragonGetBoxPrizeRequest = consortiaDragonGetBoxPrizeRequest }
    app:getClient():requestPackageHandler("CONSORTIA_DRAGON_GET_BOX_PRIZE", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional int32 multipleId                        = 1;                      // 任务倍数Id 暂定1 2 3
-- optional bool  isSecretary  = 2;                                           // 是否是小秘书
function QDragon:consortiaDragonGetTaskProgressRequest(multipleId, isSecretary, success, fail, status)
    self._dragonOldLevel = self._dragonInfo.level
    self.multipleId = multipleId
    local consortiaDragonGetTaskProgressRequest = {multipleId = multipleId, isSecretary = isSecretary}
    local request = { api = "CONSORTIA_DRAGON_GET_TASK_PROGRESS", consortiaDragonGetTaskProgressRequest = consortiaDragonGetTaskProgressRequest }
    app:getClient():requestPackageHandler("CONSORTIA_DRAGON_GET_TASK_PROGRESS", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional int32 level                          = 1;                        // 领取巨龙等级奖励
function QDragon:consortiaGetDragonLevelUpRewardRequest(level, success, fail, status)
    local consortiaGetDragonLevelUpRewardRequest = {level = level}
    local request = { api = "CONSORTIA_GET_DRAGON_LEVEL_UP_REWARD", consortiaGetDragonLevelUpRewardRequest = consortiaGetDragonLevelUpRewardRequest }
    app:getClient():requestPackageHandler("CONSORTIA_GET_DRAGON_LEVEL_UP_REWARD", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

function QDragon:consortiaDragonTaskFightEndRequest(success, fail, status)
    local consortiaDragonTaskFightEndRequest = {}
    local content = readFromBinaryFile("last.reppb")
    local fightReportData = crypto.encodeBase64(content)
    local gfEndRequest = {battleType = BattleTypeEnum.DRAGON_TASK, fightReportData = fightReportData, consortiaDragonTaskFightEndRequest = consortiaDragonTaskFightEndRequest}
    local request = {api = "GLOBAL_FIGHT_END", gfEndRequest = gfEndRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_END", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--------------本地工具--------------

function QDragon:_checkGragonUnlock(isTips)
end

function QDragon:_dispatchAll()
    if not self._dispatchTBl or table.nums(self._dispatchTBl) == 0 then return end
    local tbl = {}
    for _, name in pairs(self._dispatchTBl) do
        if not tbl[name] then
            self:dispatchEvent({name = name})
            tbl[name] = 0
        end
    end
    self._dispatchTBl = {}
end

return QDragon
