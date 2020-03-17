--[[
装备洗练次数
]]

_G.SmithingTimesGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function SmithingTimesGoalVO:GetType()
	return QuestConsts.GoalType_SmithingTimes;
end

function SmithingTimesGoalVO:DoGoal()
	
end