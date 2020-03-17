--[[
任务目标:活跃度即当前的仙阶
]]

_G.HuoYueDuGoalVO = setmetatable( {}, {__index = QuestGoalVO} )

function HuoYueDuGoalVO:GetType()
	return QuestConsts.GoalType_HuoYueDu;
end

function HuoYueDuGoalVO:CreateGoalParam()
	return nil;
end

function HuoYueDuGoalVO:CreateGuideParam()
	return nil;
end

function HuoYueDuGoalVO:DoGoal()
	local func = FuncManager:GetFunc(FuncConsts.HuoYueDu);
	if func then
		func:OnQuestClick();
	end
end