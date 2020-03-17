
--[[
加入帮派
]]

_G.LvNewTianShenFightGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function LvNewTianShenFightGoalVO:GetType()
	return QuestConsts.GoalType_NewTianShenFight;
end

function LvNewTianShenFightGoalVO:DoGoal()
	self:OpenFuncByClientParam();
end