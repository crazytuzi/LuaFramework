
--
-- Author: Kumo.Wang
-- 老玩家回歸（老服）数据管理
--

local QBaseModel = import("...models.QBaseModel")
local QPlayerRecall = class("QPlayerRecall", QBaseModel)

local QUIViewController = import("...ui.QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QActorProp = import("...models.QActorProp")

QPlayerRecall.EVENT_UPDATE = "QPLAYERRECALL.EVENT_UPDATE"

QPlayerRecall.TYPE_AWARD = "TYPE_AWARD"
QPlayerRecall.TYPE_FEATRUE = "TYPE_FEATRUE"
QPlayerRecall.TYPE_PAY = "TYPE_PAY"
QPlayerRecall.TYPE_BUFF = "TYPE_BUFF"
QPlayerRecall.TYPE_TASK = "TYPE_TASK"

function QPlayerRecall:ctor()
    QPlayerRecall.super.ctor(self)
end

function QPlayerRecall:init()
    self._info = {}
    self._dispatchTBl = {}

    self._roundNum = 1 -- 活動倫次（數據來源後端）
    self._isOpen = false -- 活动是否开启
end

function QPlayerRecall:loginEnd(callback)
    if self._isOpen then
        self:playerComeBackGetInfoRequest(callback, callback)
    else
        if callback then
            callback()
        end
    end
end

function QPlayerRecall:disappear()
    QPlayerRecall.super.disappear(self)
    self:_removeEvent()
end

function QPlayerRecall:_addEvent()
    self:_removeEvent()
    self._userEventProxy = cc.EventProxy.new(remote.user)
    self._userEventProxy:addEventListener(remote.user.EVENT_TIME_REFRESH, handler(self, self.timeRefreshHandler))
end

function QPlayerRecall:_removeEvent()
    if self._userEventProxy then
        self._userEventProxy:removeAllEventListeners()
        self._userEventProxy = nil
    end
end

--打开界面
function QPlayerRecall:openDialog(callback)
    if self._isOpen then
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityPlayerRecall"})
    end
end

function QPlayerRecall:timeRefreshHandler( event )
    if event.time and event.time == 0 then
        self:_newDayUpdate()
    end
end

--------------数据储存.KUMOFLAG.--------------

function QPlayerRecall:setInfo(info)
    self._info = info or {}
    self._roundNum = self._info.num
    local nowTimeForMsec = q.serverTime() * 1000
    local endOffsetTime = self._info.end_at - nowTimeForMsec
    self._isOpen = false
    if self._roundNum and endOffsetTime > 0 and nowTimeForMsec > self._info.start_at then
        self._isOpen = true
        app:getAlarmClock():deleteAlarmClock("playerRecallEndTime")
        app:getAlarmClock():createNewAlarmClock("playerRecallEndTime", self._info.end_at/1000, function()
                self:setInfo(self._info)
            end)
    end
    if self._isOpen then
        self:_addEvent()
        self:_createRedTips()
    else
        self:_removeEvent()
    end
end

function QPlayerRecall:updateInfo(info)
    for key, value in pairs(info) do
        if key == "taskInfo" then
            for _, task in ipairs(value) do
                local id = tostring(task.targetId)
                self._info[id] = task
            end
        else
            self._info[key] = value
        end
    end
    -- 防止登入的api不是"USER_LOGIN" or "USER_QUICK_LOGIN"的意外情况
    if not self._isOpen then
        self:setInfo(self._info)
    end
    -- QPrintTable(self._info)
    if self._isOpen then
        self:checkRedTips()
    end
end

function QPlayerRecall:isOpen()
    return self._isOpen
end

function QPlayerRecall:getInfo()
    return self._info
end

--------------调用素材.KUMOFLAG.--------------

--------------便民工具.KUMOFLAG.--------------

function QPlayerRecall:isShowRedTips()
    if remote.redTips:getTipsStateByName("QPlayerRecall_AwardButtonTips")
        or remote.redTips:getTipsStateByName("QPlayerRecall_FeatureButtonTips")
        or remote.redTips:getTipsStateByName("QPlayerRecall_PayButtonTips")
        or remote.redTips:getTipsStateByName("QPlayerRecall_TaskButtonTips") then
        return true
    end
    return false
end
function QPlayerRecall:checkRedTips()
    local awardConfigLis = self:getAwardConfigList()
    local awardRedTip = false
    for _, info in ipairs(awardConfigLis) do
        local isReady = info.day <= (self._info.login_days or 0)
        local curTaskInfo = self._info[tostring(info.id)]
        local isComplete = info.complete_count <= (curTaskInfo and curTaskInfo.awardCount or 0)
        if isReady and not isComplete then
            awardRedTip = true
            break
        end
    end
    -- print("awardRedTip = ", awardRedTip)
    remote.redTips:setTipsStateByName("QPlayerRecall_AwardButtonTips", awardRedTip)

    local featureConfigList = self:getFeatureConfigList()
    local featureRedTip = false
    for _, info in ipairs(featureConfigList) do
        local curTaskInfo = self._info[tostring(info.id)]
        local isReady = (curTaskInfo and curTaskInfo.completeCount or 0) > 0
        local isComplete = info.complete_count <= (curTaskInfo and curTaskInfo.awardCount or 0)
        if isReady and not isComplete then
            featureRedTip = true
            break
        end
    end
    -- print("featureRedTip = ", featureRedTip)
    remote.redTips:setTipsStateByName("QPlayerRecall_FeatureButtonTips", featureRedTip)

    local payConfigList = self:getPayConfigList()
    local payRedTip = false
    if not self.donotShowPayRedTip then
        for _, info in ipairs(payConfigList) do
            local curTaskInfo = self._info[tostring(info.id)]
            local isComplete = info.complete_count <= (curTaskInfo and curTaskInfo.awardCount or 0)
            if not isComplete then
                payRedTip = true
                break
            end
        end
    end
    -- print("payRedTip = ", payRedTip)
    remote.redTips:setTipsStateByName("QPlayerRecall_PayButtonTips", payRedTip)

    local taskConfigList = self:getTaskConfigList()
    local taskRedTip = false
    for _, info in ipairs(taskConfigList) do
        local curTaskInfo = self._info[tostring(info.id)]
        local isReady = (curTaskInfo and curTaskInfo.completeCount or 0) > 0
        local isComplete = info.complete_count <= (curTaskInfo and curTaskInfo.awardCount or 0)
        if isReady and not isComplete then
            taskRedTip = true
            break
        end
    end
    -- print("taskRedTip = ", taskRedTip)
    remote.redTips:setTipsStateByName("QPlayerRecall_TaskButtonTips", taskRedTip)
end

function QPlayerRecall:getAwardConfigList()
    if self._awardLevel and self._awardLevel == remote.user.level and self._awardConfigList and #self._awardConfigList > 0 then return self._awardConfigList end

    local returnList = {}
    local configs = QStaticDatabase.sharedDatabase():getStaticByName("player_comeback_huodong")
    local curRoundConfigs = configs[tostring(self._roundNum)]
    if not curRoundConfigs then return returnList end
    -- remote.user.dailyTeamLevel
    -- remote.user.level
    for _, config in pairs(curRoundConfigs) do
        if config.type == 1 then
            table.insert(returnList, config)
        end
    end
    table.sort(returnList, function(a, b)
            if a.day ~= b.day then
                return a.day < b.day
            else
                return a.id < b.id
            end
        end)

    if not self._awardConfigList then self._awardConfigList = {} end
    self._awardConfigList = returnList
    self._awardLevel = remote.user.level

    return returnList
end

function QPlayerRecall:getFeatureConfigList()
    if self._featureConfigList and #self._featureConfigList > 0 then 
        table.sort(self._featureConfigList, function(a, b)
            local aReady = (self._info[tostring(a.id)] and self._info[tostring(a.id)].completeCount or 0) > 0
            local bReady = (self._info[tostring(b.id)] and self._info[tostring(b.id)].completeCount or 0) > 0
            local aComplete = a.complete_count <= (self._info[tostring(a.id)] and self._info[tostring(a.id)].awardCount or 0)
            local bComplete = b.complete_count <= (self._info[tostring(b.id)] and self._info[tostring(b.id)].awardCount or 0)
            if aComplete ~= bComplete then
                return not aComplete
            elseif aReady ~= bReady then
                return aReady
            else
                return a.id < b.id
            end
        end)
        return self._featureConfigList 
    end

    local returnList = {}
    local configs = QStaticDatabase.sharedDatabase():getStaticByName("player_comeback_huodong")
    local curRoundConfigs = configs[tostring(self._roundNum)]
    if not curRoundConfigs then return returnList end
    
    for _, config in pairs(curRoundConfigs) do
        -- if config.type == 1 or config.type == 2 then
        if config.type == 2 or config.type == 3 then
            table.insert(returnList, config)
        end
    end
    table.sort(returnList, function(a, b)
            local aReady = (self._info[tostring(a.id)] and self._info[tostring(a.id)].completeCount or 0) > 0
            local bReady = (self._info[tostring(b.id)] and self._info[tostring(b.id)].completeCount or 0) > 0
            local aComplete = a.complete_count <= (self._info[tostring(a.id)] and self._info[tostring(a.id)].awardCount or 0)
            local bComplete = b.complete_count <= (self._info[tostring(b.id)] and self._info[tostring(b.id)].awardCount or 0)
            if aComplete ~= bComplete then
                return not aComplete
            elseif aReady ~= bReady then
                return aReady
            else
                return a.id < b.id
            end
        end)

    if not self._featureConfigList then self._featureConfigList = {} end
    self._featureConfigList = returnList

    return returnList
end

function QPlayerRecall:getPayConfigList()
    if self._payLevel and self._payLevel == remote.user.level and self._payConfigList and #self._payConfigList > 0 then 
        table.sort(self._payConfigList, function(a, b)
            local aComplete = a.complete_count <= (self._info[tostring(a.id)] and self._info[tostring(a.id)].awardCount or 0)
            local bComplete = b.complete_count <= (self._info[tostring(b.id)] and self._info[tostring(b.id)].awardCount or 0)
            if aComplete ~= bComplete then
                return not aComplete
            else
                return a.id < b.id
            end
        end)
        return self._payConfigList 
    end

    local returnList = {}
    local configs = QStaticDatabase.sharedDatabase():getStaticByName("player_comeback_huodong")
    local curRoundConfigs = configs[tostring(self._roundNum)]
    if not curRoundConfigs then return returnList end
    
    for _, config in pairs(curRoundConfigs) do
        -- if config.type == 3 and config.exchange_show <= remote.user.level then
        if config.type == 4 and config.exchange_show <= remote.user.level then
            table.insert(returnList, config)
        end
    end
    table.sort(returnList, function(a, b)
            local aComplete = a.complete_count <= (self._info[tostring(a.id)] and self._info[tostring(a.id)].awardCount or 0)
            local bComplete = b.complete_count <= (self._info[tostring(b.id)] and self._info[tostring(b.id)].awardCount or 0)
            if aComplete ~= bComplete then
                return not aComplete
            else
                return a.id < b.id
            end
        end)

    if not self._payConfigList then self._payConfigList = {} end
    self._payConfigList = returnList
    self._payLevel = remote.user.level

    return returnList
end

function QPlayerRecall:getBuffConfigList()
    if self._buffConfigList and #self._buffConfigList > 0 then return self._buffConfigList end

    local returnList = {}
    local configs = QStaticDatabase.sharedDatabase():getStaticByName("player_comeback_buff")
    
    for _, config in pairs(configs) do
        table.insert(returnList, config)
    end
    table.sort(returnList, function(a, b)
            return a.type < b.type
        end)

    if not self._buffConfigList then self._buffConfigList = {} end
    self._buffConfigList = returnList

    return returnList
end

function QPlayerRecall:getTaskConfigList()
    if self._taskConfigList and #self._taskConfigList > 0 then  
        table.sort(self._taskConfigList, function(a, b)
            local aReady = (self._info[tostring(a.id)] and self._info[tostring(a.id)].completeCount or 0) > 0
            local bReady = (self._info[tostring(b.id)] and self._info[tostring(b.id)].completeCount or 0) > 0
            local aComplete = a.complete_count <= (self._info[tostring(a.id)] and self._info[tostring(a.id)].awardCount or 0)
            local bComplete = b.complete_count <= (self._info[tostring(b.id)] and self._info[tostring(b.id)].awardCount or 0)
            if aComplete ~= bComplete then
                return not aComplete
            elseif aReady ~= bReady then
                return aReady
            else
                return a.id < b.id
            end
        end)
        return self._taskConfigList 
    end

    local returnList = {}
    -- local configs = QStaticDatabase.sharedDatabase():getStaticByName("player_comeback_tasks")
    local configs = QStaticDatabase.sharedDatabase():getStaticByName("player_comeback_huodong")
    local curRoundConfigs = configs[tostring(self._roundNum)]
    if not curRoundConfigs then return returnList end
    
    for _, config in pairs(curRoundConfigs) do
        if config.type == 5 then
            table.insert(returnList, config)
        end
    end
    table.sort(returnList, function(a, b)
            local aReady = (self._info[tostring(a.id)] and self._info[tostring(a.id)].completeCount or 0) > 0
            local bReady = (self._info[tostring(b.id)] and self._info[tostring(b.id)].completeCount or 0) > 0
            local aComplete = a.complete_count <= (self._info[tostring(a.id)] and self._info[tostring(a.id)].awardCount or 0)
            local bComplete = b.complete_count <= (self._info[tostring(b.id)] and self._info[tostring(b.id)].awardCount or 0)
            if aComplete ~= bComplete then
                return not aComplete
            elseif aReady ~= bReady then
                return aReady
            else
                return a.id < b.id
            end
        end)

    if not self._taskConfigList then self._taskConfigList = {} end
    self._taskConfigList = returnList

    return returnList
end

function QPlayerRecall:getLuckyDrawListByLuckyDrawId( luckyDrawId )
    return QStaticDatabase.sharedDatabase():getLuckyDraw(luckyDrawId)
end

function QPlayerRecall:getShortcutByID( id )
    return QStaticDatabase.sharedDatabase():getShortcutByID( id )
end

function QPlayerRecall:getLeaveDays()
    local nowTimeForMsec = q.serverTime() * 1000
    local leaveTimeForMsec = nowTimeForMsec - self._info.last_leave_at
    local days = math.floor(leaveTimeForMsec/DAY/1000)

    return days
end

function QPlayerRecall:getBuffNumByType(buffType)
    local configs = QStaticDatabase.sharedDatabase():getStaticByName("player_comeback_buff")
    
    for _, config in pairs(configs) do
        if config.type == tonumber(buffType) then
            return config.buff_num
        end
    end
    return 0
end

--------------数据处理.KUMOFLAG.--------------

function QPlayerRecall:responseHandler( response, successFunc, failFunc )
    -- QPrintTable( response )
    if response.api == "PLAYER_COME_BACK_GET_USER_INFO" and response.error == "NO_ERROR" then
        table.insert(self._dispatchTBl, {name = QPlayerRecall.EVENT_UPDATE})
    end

    if response.api == "PLAYER_COME_BACK_COMPLETE" and response.error == "NO_ERROR" then
        table.insert(self._dispatchTBl, {name = QPlayerRecall.EVENT_UPDATE})
        if response.playerComeBackCompleteResponse and response.playerComeBackCompleteResponse.luckyDraw then
            if response.playerComeBackCompleteResponse.luckyDraw.prizes then
                local awards = response.playerComeBackCompleteResponse.luckyDraw.prizes
                app.tip:awardsTip(awards, "恭喜您获得回归奖励")
            end
            if response.playerComeBackCompleteResponse.luckyDraw.items then
                remote.items:setItems(response.playerComeBackCompleteResponse.luckyDraw.items)
            end
        end
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

function QPlayerRecall:pushHandler( data )
    -- QPrintTable(data)
end

-- PLAYER_COME_BACK_GET_USER_INFO              = 9800;                     // 老玩家回归获取玩家信息  PlayerComeBackGetInfoRequest PlayerComeBackUserInfoResponse
-- PLAYER_COME_BACK_COMPLETE                   = 9801;                     // 老玩家回顾完成任务 PlayerComeBackCompleteRequest PlayerComeBackUserInfoResponse

function QPlayerRecall:playerComeBackGetInfoRequest(success, fail, status)
    local request = { api = "PLAYER_COME_BACK_GET_USER_INFO"}
    app:getClient():requestPackageHandler("PLAYER_COME_BACK_GET_USER_INFO", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional int32 type = 2;//类型
-- optional int32 targetId = 3;//目标id  传量表id
-- optional int32 count = 3;//购买次数
function QPlayerRecall:playerComeBackCompleteRequest(type, targetId, count, success, fail, status)
    local count = count or 1
    local playerComeBackCompleteRequest = {type = type, targetId = targetId, count = count}
    local request = { api = "PLAYER_COME_BACK_COMPLETE", playerComeBackCompleteRequest = playerComeBackCompleteRequest}
    app:getClient():requestPackageHandler("PLAYER_COME_BACK_COMPLETE", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--------------本地工具.KUMOFLAG.--------------

function QPlayerRecall:_dispatchAll()
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

function QPlayerRecall:_createRedTips()
    remote.redTips:createTipsNode("QPlayerRecall_AwardButtonTips")
    remote.redTips:createTipsNode("QPlayerRecall_FeatureButtonTips")
    remote.redTips:createTipsNode("QPlayerRecall_PayButtonTips")
    remote.redTips:createTipsNode("QPlayerRecall_TaskButtonTips")
end

function QPlayerRecall:_newDayUpdate()
    for key, value in pairs(self._info or {}) do
        if type(value) == "table" and value.type == 4 then
            value.awardCount = 0
        end
    end
    self._info.login_days = self._info.login_days + 1
    self:dispatchEvent({name = QPlayerRecall.EVENT_UPDATE})
end

return QPlayerRecall
