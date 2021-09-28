--自动提交任务
TaskAutoComit = class("TaskAutoComit", SequenceContent)

function TaskAutoComit.GetSteps()
    return {
        TaskAutoComit.A
        ,TaskAutoComit.B
    };
end

function TaskAutoComit.A(seq)
    local cfg = seq:GetCfg();
    local npcId = cfg.com_npcid;

    if seq:IsPay() then
        return SequenceCommand.Task.TransmitToNpc(npcId);
    end
    return SequenceCommand.Common.GoToNpc(npcId);
end

function TaskAutoComit.B(seq)
    local cfg = seq:GetCfg();
    local npcId = cfg.com_npcid;
        ModuleManager.SendNotification(DialogNotes.OPEN_DIALOGPANEL, npcId);
    return nil;
    --等待1.5s
    --return SequenceCommand.Delay(1.5);
end

--[[
function TaskAutoComit.C(seq)
    --自动提交
    --local task = seq:GetTask();
    --TaskProxy.ReqTaskFinish(task.id);
    return nil;
end
]]