--[[
世界BOSS
]]

_G.WorldBossGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function WorldBossGoalVO:GetType()
	return QuestConsts.GoalType_WorldBoss;
end

function WorldBossGoalVO:DoGoal()
	
end