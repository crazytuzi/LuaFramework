TaskUpgradeSkill =BaseClass(TaskBehavior)
function TaskUpgradeSkill:__init(taskData)
	self:InitEvent()
end

function TaskUpgradeSkill:__delete()
end

function TaskUpgradeSkill:InitEvent()
	TaskBehavior.InitEvent(self)

end


function TaskUpgradeSkill:Behavior()
	self:SetTaskTargetType(TaskConst.TaskTargetType.UpgradeSkill)

	--self:SetSkillInfo()
	
	if self.taskData:GetTaskState() == TaskConst.TaskState.Finish then --以后端为准
		
		self:SubmitTask()
	else
		if (not self.taskData:IsGuideTask()) or (self.taskData:IsGuideTask() and  self.taskData:GetGuideTaskExecCnt() >= 1) then
			SkillController:GetInstance():OpenSkillPanel()
		end
	end
end

function TaskUpgradeSkill:SetSkillInfo()
	local skillId = -1
	local targetSkillLev = -1
	local taskDataObj = self:GetTaskData()
	if taskDataObj then
		local taskTarget = taskDataObj:GetTaskTarget()
		if taskTarget then
			self.skillId= taskTarget.targetParam[1] or -1
			self.targetSkillLev = taskTarget.targetParam[2] or -1
		end
	end
end


function TaskUpgradeSkill:IsTaskFinish()
	local rtnIsFinish = false
	if rtnIsFinish == false then
		if self:IsHasInitSkill() == true then
			local targetSkillId = SkillModel:GetInstance():GetSkillIdByIdLev(self.skillId, self.targetSkillLev)
			--local isHasSkill = SkillModel:GetInstance():GetSkillById(targetSkillId)
			local nowLev = SkillModel:GetInstance():GetLevelBySkillId(targetSkillId)
			if  SkillModel:GetInstance():IsNoLessThanSkillId(targetSkillId) == true then
				rtnIsFinish = true
			end
		end
	end
	return rtnIsFinish
end

function TaskUpgradeSkill:IsHasInitSkill()
	local rtnIsInited = false
	if self.skillId and self.skillId ~= -1 and self.targetSkillLev and self.targetSkillLev ~= -1 then
		rtnIsInited = true
	end
	return rtnIsInited
end