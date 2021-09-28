--通关到大荒塔n层
-- 大荒塔：
-- 不在大荒塔的场景内时：点击打开“神境”界面
-- 在大荒塔场景内：弹tips“请通关大荒塔”

TaskClimbTowerCounter = BaseClass(TaskBehavior)

function TaskClimbTowerCounter:__init(taskData)
	self:InitEvent()
end

function TaskClimbTowerCounter:InitEvent()
	TaskBehavior.InitEvent(self)
end

function TaskClimbTowerCounter:__delete()

end

function TaskClimbTowerCounter:Behavior()
	self:SetTaskTargetType(TaskConst.TaskTargetType.ClimbTowerCounter)

	if self.taskData:GetTaskState() == TaskConst.TaskState.Finish then
		self:SubmitTask()
	elseif self.taskData:GetTaskState() == TaskConst.TaskState.NotFinish then
		if SceneModel:GetInstance():IsTower() then
			UIMgr.Win_FloatTip("请通关大荒塔")
		else
			self:OpenClimbTowerPanel()
		end
	end
end

function TaskClimbTowerCounter:OpenClimbTowerPanel()
	ShenJingController:GetInstance():OpenShenJingPanel()
end
