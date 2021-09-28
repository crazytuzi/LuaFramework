local PomeloUtil = require "Zeus.Logic.PomeloUtil"
local Player = require "Zeus.Model.Player"
local DailyThing = {}
local isInited = false
local isFirstSceneInited = false
local lastTaskId = nil


function DailyThing.requestVitalityInfo(cb, failCb)
    PomeloUtil.wrapRequest(
        Pomelo.VitalityHandler.getVitalityListRequest, 
        function(data)
            
            cb(data.s2c_vitalityList, data.s2c_awardList, data.s2c_totalCurrCount, data.s2c_totalMaxCount)
        end, failCb
    )
end

function DailyThing.requestVitalityReward(rewardId, cb)
    Pomelo.VitalityHandler.getVitalityRewardRequest(rewardId, function(ex, sjson)
        if ex then return end

        cb()
    end)
end

function DailyThing.requestRecommendPlayList(cb, failCb)
    PomeloUtil.wrapRequest(
        Pomelo.VitalityHandler.getRecommendPlayListRequest, 
        function(data)
            
            cb(data.s2c_recommendPlayList)
        end, failCb
    )
end

local soulIdx = nil



local taskMap = {}

local taskCircleList = {}

function DailyThing.getTaskCircleList()
    return taskCircleList
end

function DailyThing.getTaskInfo(taskId)
    return taskMap[taskId]
end



function DailyThing.getDailyTaskTimes(taskCycleType)
    local _, circle = table.indexOfKey(taskCircleList, "cycleType", taskCycleType)
    if circle then
        for _, v in ipairs(circle.list) do
            if taskMap[v] then
                return taskMap[v].currIdx, circle.len
            end
        end
    end
    return nil, nil
end

local function createCircle(task)
    local taskId = task.TemplateID
    local staticVo = GlobalHooks.DB.Find("Tasks", taskId)
    local list = GlobalHooks.DB.Find("Tasks", {TaskCycle = staticVo.TaskCycle})
    local circle = { cycleType = staticVo.TaskCycle, currTaskId = taskId, list = {}}
    if task.SubType == QuestData.EventType.RefineSoul then
        local ret = GlobalHooks.DB.Find("Parameters", {ParamName = "Quest.Soul.DailyLimit"})
        circle.len = tonumber(ret[1].ParamValue)
        for _,v in ipairs(list) do
            table.insert(circle.list, v.ID)
        end
    else
        local map = {}
        for _,v in ipairs(list) do
            if v.ID ~= nil then
              map[v.ID] = v  
            end
        end
        table.insert(circle.list, taskId)
        local tmp = staticVo
        while tmp and tmp.Before ~= '0' and tmp.Before ~= "" do
            table.insert(circle.list, 1, tonumber(tmp.Before))
            tmp = map[tonumber(tmp.Before)]
            if not tmp then print("can not fond befor daily task id") end
        end
        tmp = staticVo
        while tmp and tmp and tmp.Next ~= '0' and tmp.Next ~= "" do
            table.insert(circle.list, tonumber(tmp.Next))
            tmp = map[tonumber(tmp.Next)]
            if not tmp then print("can not fond next daily task id") end
        end
        circle.len = #circle.list
    end
    return circle
end

function DailyThing.tryAddTask(task, ignoreEvent)
    local taskId = task.TemplateID
    
    if taskMap[taskId] then
        taskMap[taskId].task = task
        if not ignoreEvent then
            EventManager.Fire("Event.DailyThing.TASK_UPDATE", {taskId = taskId, task = task})
        end
        return
    end

    
    local circle = nil
    for i,v in ipairs(taskCircleList) do
        if table.indexOf(v.list, taskId) then
            circle = v
            break
        end
    end

    
    local isCreateCircle = not circle
    if not circle then
        circle = createCircle(task)
        table.insert(taskCircleList, circle)
        table.sort(taskCircleList, function(a, b) return a.cycleType < b.cycleType end)
    end

    
    taskMap[taskId] = {task = task, circle = circle}
    circle.currTaskId = taskId
    if task.SubType == QuestData.EventType.RefineSoul then
        if not soulIdx then
            soulIdx = Player.GetBindPlayerData().dailySoulFinNum or 1
        end
        if soulIdx < 1 then soulIdx = 1 end
        taskMap[taskId].currIdx = soulIdx
    else
        taskMap[taskId].currIdx = table.indexOf(circle.list, taskId)
    end

    if not ignoreEvent then
        EventManager.Fire("Event.DailyThing.TASK_NEW", {
            taskId = taskId,
            circle = circle,
            task = task,
            isNewCircle = isCreateCircle
        })
    end
end


function DailyThing.doneTask(task)
    local taskInfo = taskMap[task.TemplateID]
    if not taskInfo then return end

    taskMap[task.TemplateID] = nil

    if task.SubType == QuestData.EventType.RefineSoul then
        
        soulIdx = soulIdx + 1
    end

    
    if taskInfo.currIdx >= taskInfo.circle.len then
        table.removeItem(taskCircleList, taskInfo.circle)
        EventManager.Fire("Event.DailyThing.TASK_CIRCLE_DONE", {cycleType = taskInfo.circle.cycleType})
    end
end

function DailyThing.Notify(taskId, questMgr)
    local task = questMgr:GetQuest(taskId)
    if not task or task.Type ~= QuestData.QuestType.DAILY then return end

    if task.State == QuestData.QuestStatus.IN_PROGRESS then
        DailyThing.tryAddTask(task)
    elseif task.State == QuestData.QuestStatus.CAN_FINISH then
        DailyThing.tryAddTask(task, true)
        EventManager.Fire("Event.DailyThing.TASK_CAN_FINISH", {taskId = task.TemplateID, task = task})
        
        
        if isFirstSceneInited then
           
        else
            lastTaskId = task.TemplateID
        end
    elseif task.State == QuestData.QuestStatus.DONE then
        DailyThing.doneTask(task)
    elseif task.State == QuestData.QuestStatus.NONE then
        taskMap[taskId] = nil
    end
end

function DailyThing.fin(relogin)
    if relogin then
        isInited = false
        DataMgr.Instance.QuestManager:DetachLuaObserver(10568)
    end
end

function DailyThing.initial()
    if isInited then return end
    isInited = true
    soulIdx = nil
    isFirstSceneInited = false
    lastTaskId = nil
    taskMap = {}
    taskCircleList = {}

    local questMgr = DataMgr.Instance.QuestManager
    questMgr:AttachLuaObserver(10568, DailyThing)
    local list = questMgr:GetAllQuest()
    
    for i = 0, list.Count - 1 do
        local v = list:get_Item(i)
        if v.Type == QuestData.QuestType.DAILY then
            DailyThing.Notify(v.TemplateID, questMgr)
        end
    end

    EventManager.Subscribe("Event.Scene.FirstInitFinish", function()
        isFirstSceneInited = true
        if lastTaskId then
          
        end
    end)
end

function DailyThing.InitNetWork()
end

return DailyThing
