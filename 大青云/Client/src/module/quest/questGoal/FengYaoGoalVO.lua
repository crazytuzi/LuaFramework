--[[
任务目标:封妖
lizhuangzhuang
2015年8月2日12:27:10
]]

_G.FengYaoGoalVO = setmetatable( {}, {__index = QuestGoalVO} )

function FengYaoGoalVO:GetType()
	return QuestConsts.GoalType_FengYao;
end

function FengYaoGoalVO:CreateGoalParam()
	return nil;
end

function FengYaoGoalVO:CreateGuideParam()
	return nil;
end

function FengYaoGoalVO:DoGoal()
	local state = FengYaoModel.fengyaoinfo.curState;
	if state == FengYaoConsts.ShowType_Accepted then
		UIFengYao:OnbtnFindRoadClick();
		return;
	end
	local func = FuncManager:GetFunc(FuncConsts.FengYao);
	if func then
		func:OnQuestClick();
	end
end