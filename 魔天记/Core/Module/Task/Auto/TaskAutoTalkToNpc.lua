--自动找NPC
TaskAutoTalkToNpc = class("TaskAutoTalkToNpc", SequenceContent)

function TaskAutoTalkToNpc.GetSteps()
    return {
        TaskAutoTalkToNpc.A
        ,TaskAutoTalkToNpc.B
    };
end

function TaskAutoTalkToNpc.Trans(seq)
    local task = seq:GetTask();
    return SequenceCommand.Task.TaskTransmit(task);
end

function TaskAutoTalkToNpc.A(seq)
    --找NPC位置,如果到了位置,则打开对话窗口, 否则进行寻路
    local cfg = seq:GetCfg();
    local npcId = tonumber(cfg.target[1]);

    if seq:IsPay() then
        return SequenceCommand.Task.TransmitToNpc(npcId);
    end
    return SequenceCommand.Common.GoToNpc(npcId);
end

function TaskAutoTalkToNpc.B(seq)
    --打开对话窗口
    local cfg = seq:GetCfg();
    local npcId = tonumber(cfg.target[1]);
    ModuleManager.SendNotification(DialogNotes.OPEN_DIALOGPANEL, npcId);
    return nil;
end


