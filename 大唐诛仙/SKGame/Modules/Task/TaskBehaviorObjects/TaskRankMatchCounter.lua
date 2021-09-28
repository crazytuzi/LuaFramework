-- 1 侍魂殿匹配成功n次。task表中的conditionType参数为20。condition参数为需要匹配的次数
--   1.1 只要点开侍魂殿，玩家匹配到对手即可计数。
--   1.2 接取任务后，点击侍魂殿类型的任务，弹出tips“请通过主界面的“侍魂殿”图标进入侍魂殿”

TaskRankMatchCounter = BaseClass(TaskBehavior)

function TaskRankMatchCounter:__init(taskDataObj)
	-- zy("====xxxxxxxxxxxxxxxxxx TaskRankMatchCounter " , taskDataObj)
	self:InitEvent()
end

function TaskRankMatchCounter:__delete()
	
end

function TaskRankMatchCounter:InitEvent()
	TaskBehavior.InitEvent(self)
end

function TaskRankMatchCounter:Behavior()
	self:SetTaskTargetType(TaskConst.TaskTargetType.RankMatchCounter)

	if self.taskData:GetTaskState() == TaskConst.TaskState.Finish then
		-- zy("============ TaskRankMatchCounter:Behavior Finish ")
		self:SubmitTask()
	elseif self.taskData:GetTaskState() == TaskConst.TaskState.NotFinish then
		-- zy("======= TaskRankMatchCounter:Behavior NotFinish")
		self:OpenRankPanel()
		--UIMgr.Win_FloatTip("请通过主界面的“侍魂殿”图标进入侍魂殿")
	end
end


function TaskRankMatchCounter:OpenRankPanel()
	TiantiController:GetInstance():Open()
end
