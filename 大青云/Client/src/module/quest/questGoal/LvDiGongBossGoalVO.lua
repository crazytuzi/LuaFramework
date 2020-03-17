--[[
地宫BOSS
]]

_G.DiGongBossGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function DiGongBossGoalVO:GetType()
	return QuestConsts.GoalType_DiGongBoss;
end

function DiGongBossGoalVO:DoGoal()
	
end