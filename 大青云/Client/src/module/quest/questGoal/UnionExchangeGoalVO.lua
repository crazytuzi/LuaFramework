
--[[
加入帮派
]]

_G.UnionExchangeGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function UnionExchangeGoalVO:GetType()
	return QuestConsts.GoalType_UnionExchange;
end

function UnionExchangeGoalVO:DoGoal()
	self:OpenFuncByClientParam();
end