TaskSeqStartEscort = class("TaskSeqStartEscort", SequenceContent);

function TaskSeqStartEscort.GetSteps()
    return {
        TaskSeqStartEscort.A
        ,TaskSeqStartEscort.B
        ,TaskSeqStartEscort.C
    };
end

--[[
--开始护送的脚本有可能存在多个.
function TaskAutoSeqStartEscort:Test(selfParam, param)
    return selfParam.id == param;
end
]]

function TaskSeqStartEscort.A(seq)
    --显示任务接取对话. 等待对话完毕
    local task = seq:GetTask();
    local ds = DialogSet.InitWithNewTaskDialog(task);
    --log("打开任务接取对话");
    if ds then
        ModuleManager.SendNotification(DialogNotes.OPEN_DIALOGPANEL, ds);
        return SequenceCommand.WaitForEvent(SequenceEventType.Base.TALK_END);
    end
    return nil;
end

function TaskSeqStartEscort.B(seq)
    --向后端激活护送NPC, 等待激活完毕
    local task = seq:GetTask();
    local taskId = task.id;
    --log("激活护送任务:"..taskId);
    TaskProxy.ReqTaskEscort(taskId);
    local filter = function(args) return (args == taskId) end;
    return SequenceCommand.WaitForEvent(SequenceEventType.Base.TASK_ESCORT_START, nil, filter);
end

function TaskSeqStartEscort.C(seq)
    local cfg = seq:GetCfg();
    local targetId = tonumber(cfg.target[3]);
    HeroController.GetInstance():StartAutoEscort(targetId);
    return nil;
end

