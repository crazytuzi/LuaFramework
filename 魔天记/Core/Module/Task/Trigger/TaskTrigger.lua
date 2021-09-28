require "Core.Trigger.Trigger";

TaskTrigger = class("TaskTrigger", Trigger);

function TaskTrigger:_Init(id, data)
    self.id = "task" .. id;
    self.taskId = id;
end

function TaskTrigger.GetTrigger(taskInfo)
    local trigger = nil;
    if (taskInfo.tType == TaskConst.Target.TALK or 
            taskInfo.tType == TaskConst.Target.FIND) then
        --找人, 对话
        local npcId = tonumber( (taskInfo.tType == TaskConst.Target.FIND) and taskInfo._config.target[1] or taskInfo._config.com_npcid );
        
        if (npcId > 0) then
            if (taskInfo.tType == TaskConst.Target.TALK) then
                trigger = TaskTriggerTalkToNpcOpen.New(taskInfo.id, npcId);
            else
                trigger = TaskTriggerTalkToNpc.New(taskInfo.id, npcId);
            end
        else
            error("task config error - " .. taskInfo.id);
        end
    elseif (taskInfo.tType == TaskConst.Target.KILL or taskInfo.tType == TaskConst.Target.DROP) then
        --杀怪 and 杀怪掉落
        trigger = TaskTriggerAutoFight.New(taskInfo.id, taskInfo._config.target);
    elseif (taskInfo.tType == TaskConst.Target.EXPLORE) then
        --区域探索
        trigger = TaskTriggerExplore.New(taskInfo.id, taskInfo._config.target);
    elseif (taskInfo.tType == TaskConst.Target.USE_ITEM) then
        --使用物品
        trigger = TaskTriggerAction.New(taskInfo.id, taskInfo._config);
    elseif (taskInfo.tType == TaskConst.Target.COLLECT) then
        --采集
        trigger = TaskTriggerCollect.New(taskInfo.id, taskInfo._config);
    elseif (taskInfo.tType == TaskConst.Target.MONSTER) then
        --刷怪
        trigger = TaskTriggerMonster.New(taskInfo.id, taskInfo._config);
    elseif (taskInfo.tType == TaskConst.Target.ESCORT) then
        --护送
        trigger = TaskTriggerEscort.New(taskInfo.id, taskInfo._config);
    elseif (taskInfo.tType == TaskConst.Target.VEHICLE) then
        --飞行载具
        trigger = TaskTriggerFlyVehicle.New(taskInfo.id, taskInfo._config);
    elseif (taskInfo.tType == TaskConst.Target.VKILL) then
        --载具杀怪
        trigger = TaskTriggerVehicleFight.New(taskInfo.id, taskInfo._config);
    elseif (taskInfo.tType == TaskConst.Target.VACTION) then
        --载具使用物品
        trigger = TaskTriggerVehicleAction.New(taskInfo.id, taskInfo._config);
        
    end
    return trigger;
end

