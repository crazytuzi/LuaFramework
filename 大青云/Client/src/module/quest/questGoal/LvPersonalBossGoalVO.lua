--[[
个人BOSS
]]

_G.PersonalBossGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function PersonalBossGoalVO:GetType()
	return QuestConsts.GoalType_PersonalBoss;
end

function PersonalBossGoalVO:DoGoal()
	
end