--[[
竞技场
]]

_G.JinJiChangGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function JinJiChangGoalVO:GetType()
	return QuestConsts.GoalType_JinJiChang;
end

function JinJiChangGoalVO:DoGoal()
	
end