--[[
战斗力达到
lizhuangzhuang
2015-10-5 21:30:55
]]

_G.FightToGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function FightToGoalVO:GetType()
	return QuestConsts.GoalType_FightTo;
end

function FightToGoalVO:DoGoal()

end