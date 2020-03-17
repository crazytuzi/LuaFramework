--[[
宝甲等级
]]

_G.BaoJiaLevelToGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function BaoJiaLevelToGoalVO:GetType()
	return QuestConsts.GoalType_BaoJiaLevelTo;
end

function BaoJiaLevelToGoalVO:DoGoal()
	
end