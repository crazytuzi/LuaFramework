--完成n次悬赏任务
-- 悬赏任务：
-- 身上没有环任务：走到npc处，打开接任务界面。
-- 已有悬赏任务：弹tips“请完成已接取的悬赏任务”
TaskDailyCounter = BaseClass(TaskBehavior)

function TaskDailyCounter:__init(taskData)
	self:InitEvent()
end

function TaskDailyCounter:InitEvent()
	TaskBehavior.InitEvent(self)
end

function TaskDailyCounter:__delete()

end


function TaskDailyCounter:Behavior()
	self:SetTaskTargetType(TaskConst.TaskTargetType.DailyTaskCounter)
	if self.taskData:GetTaskState() == TaskConst.TaskState.Finish then
		self:SubmitTask()
	elseif self.taskData:GetTaskState() == TaskConst.TaskState.NotFinish then
		if TaskModel:GetInstance():IsHasDailyTask() then
			UIMgr.Win_FloatTip("请完成已接取的悬赏任务")
		else
			GuideController:GetInstance():GoToNPC(TaskConst.DailyNPCID)
		end
	end
end