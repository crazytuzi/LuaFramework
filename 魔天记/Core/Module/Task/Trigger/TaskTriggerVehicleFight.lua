TaskTriggerVehicleFight = class("TaskTriggerVehicleFight", TaskTriggerVehicle);


function TaskTriggerVehicleFight:OnEvent(sequenceEventType, param)
	self.super.OnEvent(self, sequenceEventType, param);
	
    if (sequenceEventType == SequenceEventType.Base.TASK_FINISH or sequenceEventType == SequenceEventType.Base.TASK_END) and param == self.taskId then
        self:OnTaskFinish();
    end
end

function TaskTriggerVehicleFight:OnTaskFinish()
	PlayerManager.hero:StopAutoKill();
end
