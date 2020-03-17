--[[
任务目标:挖宝
lizhuangzhuang
2015年8月1日23:59:37
]]

_G.WaBaoGoalVO = setmetatable( {}, {__index = QuestGoalVO} )

function WaBaoGoalVO:GetType()
	return QuestConsts.GoalType_Click
end

function WaBaoGoalVO:CreateGoalParam()
	return nil;
end

function WaBaoGoalVO:CreateGuideParam()
	return nil;
end

function WaBaoGoalVO:DoGoal()
	local func = FuncManager:GetFunc(FuncConsts.WaBao);
	if func then
		func:OnQuestClick();
	end
end

function WaBaoGoalVO:GetGoalLabel(size, color)
	
end
