TaskTriggerTalkToNpcOpen = class("TaskTriggerTalkToNpcOpen", TaskTrigger);

function TaskTriggerTalkToNpcOpen:_SetParam(data)
    self.npcId = data;
    self.task = TaskManager.GetTaskById(self.taskId);
end

function TaskTriggerTalkToNpcOpen:OnEvent(sequenceEventType, param)
    if(sequenceEventType ~= SequenceEventType.Base.TALK_TO_NPC_PRE) then
        return;
    end
    if (param == self.npcId) then
        self:Result(true);
    end
end

function TaskTriggerTalkToNpcOpen:Result(bool)
	if self.task.status2 == TaskConst.Status.IMPLEMENTATION then
    	TaskProxy.ReqTaskTrigger(self.taskId);
   	end
    --TaskManager.RemoveTriggerById(self.taskId);
end
