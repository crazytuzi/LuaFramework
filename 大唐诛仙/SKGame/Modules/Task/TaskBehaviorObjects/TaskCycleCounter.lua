--完成n次环任务
-- 环任务
-- 身上没有环任务：，走到npc处，打开接任务界面。
-- 已有环任务：弹tips“请完成已接取的环任务”
TaskCycleCounter = BaseClass(TaskBehavior)

function TaskCycleCounter:__init(taskData)
	self:InitEvent()
end

function TaskCycleCounter:InitEvent()
	TaskBehavior.InitEvent(self)
end

function TaskCycleCounter:__delete()

end


function TaskCycleCounter:Behavior()
	self:SetTaskTargetType(TaskConst.TaskTargetType.CycleTaskCounter)
	if self.taskData:GetTaskState() == TaskConst.TaskState.Finish then
		self:SubmitTask()
	elseif self.taskData:GetTaskState() == TaskConst.TaskState.NotFinish then
		if TaskModel:GetInstance():IsHasCycleTask() then
			UIMgr.Win_FloatTip("请完成已接取的环任务")
		else
			GuideController:GetInstance():GoToNPC(TaskConst.CycleNPCID)
		end
	end
end
