--[[
金币BOSS
]]

_G.GoldBossGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function GoldBossGoalVO:GetType()
	return QuestConsts.GoalType_GoldBoss;
end

function GoldBossGoalVO:DoGoal()
	
end