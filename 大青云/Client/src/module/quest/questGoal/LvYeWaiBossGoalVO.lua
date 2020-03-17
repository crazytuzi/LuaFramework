--[[
野外BOSS
]]

_G.YeWaiBossGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function YeWaiBossGoalVO:GetType()
	return QuestConsts.GoalType_YeWaiBoss;
end

function YeWaiBossGoalVO:DoGoal()
	
end