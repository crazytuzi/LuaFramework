require "Core.Module.Task.Trigger.TaskTrigger";
require "Core.Module.Task.Trigger.TaskTriggerCollect";
require "Core.Module.Task.Trigger.TaskTriggerAction";
require "Core.Module.Task.Trigger.TaskTriggerExplore";
require "Core.Module.Task.Trigger.TaskTriggerAutoFight";
require "Core.Module.Task.Trigger.TaskTriggerMonster";
require "Core.Module.Task.Trigger.TaskTriggerTalkToNpcOpen";
require "Core.Module.Task.Trigger.TaskTriggerTalkToNpc";
require "Core.Module.Task.Trigger.TaskTriggerEscort";
require "Core.Module.Task.Trigger.TaskTriggerFlyVehicle";
require "Core.Module.Task.Trigger.TaskTriggerVehicle";
require "Core.Module.Task.Trigger.TaskTriggerVehicleFight";
require "Core.Module.Task.Trigger.TaskTriggerVehicleAction";


TriggerManager = class("TriggerManager");
TriggerManager.DEBUG = false;
TriggerManager.TRIGGER_INTERVAL = 0.25;  --触发器检查的间隔
TriggerManager._triggers = {};

function TriggerManager.Init()
    if TriggerManager.DEBUG and TriggerManager.debugGo == nil then
        TriggerManager.debugGo = GameObject.New("TriggerManager");
        TriggerManager.debugGo:DontDestroyOnLoad();
    end
end

function TriggerManager.Clear()
    for k, v in pairs(TriggerManager._triggers) do
        v:Dispose();
    end
    TriggerManager._triggers = {};
    TriggerManager._StopTimer();
end

function TriggerManager._SetTimer(duration)
    if (TriggerManager._timer) then
        TriggerManager._timer:Reset( function(val) TriggerManager._OnTickHandler(val) end, duration, -1, false);
    else
        TriggerManager._timer = Timer.New( function(val) TriggerManager._OnTickHandler(val) end, duration, -1, false);
    end 
    TriggerManager._timer:Start();
end 

function TriggerManager._StopTimer()
    if (TriggerManager._timer) then
        TriggerManager._timer:Stop();
        TriggerManager._timer = nil;
    end
end

function TriggerManager._OnTickHandler()
    for k, v in pairs(TriggerManager._triggers) do
        if (v:NeedUpdate() == true and v:IsActive() == true) then
            v:Update();
        end
    end
end

function TriggerManager.TriggerEvent(eventType, param)
    for k, v in pairs(TriggerManager._triggers) do
        if v:IsActive() then
            v:OnEvent(eventType, param);    
        end
    end
end

--激活触发器
function TriggerManager.ActiveTrigger(taskId)
    for k,v in pairs(TriggerManager._triggers) do
        if(k == taskId) then 
            v._active = true;
            break;
        end
    end
end

function TriggerManager.AddTrigger(trigger)
    if (trigger ~= nil) then
        if TriggerManager.DEBUG then
            trigger.gameObject = NGUITools.AddChild(TriggerManager.debugGo);
            trigger.gameObject.name = trigger.__cname .. "_" .. trigger.id;
        end
        TriggerManager._triggers[trigger.id] = trigger;
    end
    TriggerManager.CheckTimer();
end

function TriggerManager.AddTaskTrigger(task)
    local trigger = TaskTrigger.GetTrigger(task);
    TriggerManager.AddTrigger(trigger);
end

function TriggerManager.RemoveTaskTrigger(taskId)
    local id = "task"..taskId;
    local trigger = TriggerManager._triggers[id];
    if (trigger ~= nil) then
        if  TriggerManager.DEBUG then
            trigger.gameObject:Destroy();
        end
        trigger:Dispose();
        TriggerManager._triggers[id] = nil;
    end
    TriggerManager.CheckTimer();
end

function TriggerManager.CheckTimer()    
    local val = false;
    for k,v in pairs(TriggerManager._triggers) do
        if(v:NeedUpdate() and v:IsActive()) then 
            val = true; 
            break;
        end
    end
    
    if (val) then
        TriggerManager._SetTimer(TriggerManager.TRIGGER_INTERVAL);
    else
        TriggerManager._StopTimer();
    end
end

