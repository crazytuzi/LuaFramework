--[[
玉佩等级
]]

_G.MingYuLevelToGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function MingYuLevelToGoalVO:GetType()
	return QuestConsts.GoalType_MingYuLevelTo;
end

function MingYuLevelToGoalVO:DoGoal()
	
end