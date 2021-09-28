TaskTriggerAutoFight = class("TaskTriggerAutoFight", TaskTrigger);

function TaskTriggerAutoFight:OnEvent(sequenceEventType, param)
	--监听任务完成. 任务结束.
    if (sequenceEventType == SequenceEventType.Base.TASK_FINISH or sequenceEventType == SequenceEventType.Base.TASK_END) and param == self.taskId then
        self:OnTaskFinish();
    end
end

function TaskTriggerAutoFight:OnTaskFinish()
	PlayerManager.hero:StopAutoKill();
end
