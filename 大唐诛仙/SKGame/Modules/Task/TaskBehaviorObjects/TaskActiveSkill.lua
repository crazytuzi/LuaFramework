TaskActiveSkill =BaseClass(TaskBehavior)
function TaskActiveSkill:Behavior()
	self:SetTaskTargetType(TaskConst.TaskTargetType.ActiveSkill)

	if self.taskData:GetTaskState() == TaskConst.TaskState.Finish then
		
		self:SubmitTask()
	elseif self.taskData:GetTaskState() == TaskConst.TaskState.NotFinish then
		
		self:OpenSkillPanel()
	end
end

function TaskActiveSkill:OpenSkillPanel()
	local skillId = self:GetTargetSkillId()
	if skillId ~= -1 then
		SkillModel:GetInstance():SetCurLearnSkillId(skillId)
		SkillController:GetInstance():OpenSkillPanelById(skillId)
	end
end

--[[
	{技能ID} id按照职业顺序：战士、冰剑、暗巫依次填入
]]
function TaskActiveSkill:GetTargetSkillId()
	local rtnSkillId = -1
	local player = SceneModel:GetInstance():GetMainPlayer()
	local taskTarget = self.taskData:GetTaskTarget()
	if player and (not TableIsEmpty(taskTarget)) then
		rtnSkillId = SkillModel:GetInstance():GetLearnSkillIdByIndex(player.career , taskTarget.targetParam[1] or -1) 
	end
	
	return rtnSkillId
end

function TaskActiveSkill:InitEvent()
	TaskBehavior.InitEvent(self)
end

function TaskActiveSkill:__init(taskData)
	
	self:InitEvent()
end

function TaskActiveSkill:__delete()
	
end