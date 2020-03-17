--[[
通关副本任务
2016年9月24日
yanghongbin
]]

_G.CompleteDungenonGoalVO = setmetatable( {}, {__index = QuestGoalVO} )

function CompleteDungenonGoalVO:GetType()
	return QuestConsts.GoalType_CompleteDungenon;
end

function CompleteDungenonGoalVO:DoGoal(auto)
	FuncManager:OpenFunc(self.goalParam[1]);
end

function CompleteDungenonGoalVO:GetGoalLabel(size, color)
	local format = "<font size='%s' color='%s'>%s</font>"
	if not size then size = 14 end
	if not color then color = "#ffffff" end
	local strSize = tostring( size )
	local name = self:GetLabelContent()
	return string.format( format, strSize, color, name )
end

function CompleteDungenonGoalVO:GetLabelContent()
	local questCfg = self.questVO:GetCfg()
	return questCfg.unFinishLink
end