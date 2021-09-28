TaskTriggerTalkToNpc = class("TaskTriggerTalkToNpc", TaskTrigger);

function TaskTriggerTalkToNpc:_SetParam(data)
    self.npcId = data;
end

function TaskTriggerTalkToNpc:OnEvent(sequenceEventType, param)
    if(sequenceEventType ~= SequenceEventType.Base.TALK_TO_NPC) then
        return;
    end
    if (param == self.npcId) then
        self:Result(true);
    end
end

function TaskTriggerTalkToNpc:Result(bool)
    TaskProxy.ReqTaskTrigger(self.taskId);
    --TaskManager.RemoveTriggerById(self.taskId);
end
