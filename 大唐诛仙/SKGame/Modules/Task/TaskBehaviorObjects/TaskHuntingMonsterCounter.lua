-- 完成猎妖令n次，task表中的参数为27，condition参数为需要完成的次数

--   2.1接取任务后，点击猎妖令类型的任务，若身上没有猎妖令任务，则弹出tips“请使用猎妖令接取任务”

--   2.2点击猎妖令类型的任务，若身上有猎妖令任务，则弹出tips“请完成已接的猎妖令任务”

--   2.3只要完成猎妖令的任务，即可计数。
TaskHuntingMonsterCounter  = BaseClass(TaskBehavior)

function TaskHuntingMonsterCounter:__init(taskData)
	
	self:InitEvent()
end

function TaskHuntingMonsterCounter:__delete()
	
end

function TaskHuntingMonsterCounter:InitEvent()
	TaskBehavior.InitEvent(self)

end

function TaskHuntingMonsterCounter:Behavior()
	self:SetTaskTargetType(TaskConst.TaskTargetType.HuntingMonsterCounter)

	if self.taskData:GetTaskState() == TaskConst.TaskState.Finish then
		
		self:SubmitTask()
	elseif self.taskData:GetTaskState() == TaskConst.TaskState.NotFinish then
		zy("=====TaskHuntingMonsterCounter NotFinish")
		
		if TaskModel:GetInstance():IsHasHuntingMonsterTask() then
			UIMgr.Win_FloatTip("请完成已接的猎妖令任务")
		else
			UIMgr.Win_FloatTip("请使用猎妖令接取任务")
		end
	end
end
