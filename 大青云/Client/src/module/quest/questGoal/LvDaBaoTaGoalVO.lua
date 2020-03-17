--[[
打宝塔
]]

_G.DaBaoTaGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function DaBaoTaGoalVO:GetType()
	return QuestConsts.GoalType_DaBaoTa;
end

function DaBaoTaGoalVO:DoGoal()
	
end