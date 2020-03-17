
--[[
加入帮派
]]

_G.LvNewTianShenLvUpGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function LvNewTianShenLvUpGoalVO:GetType()
	return QuestConsts.GoalType_NewTianShenLvUp;
end

function LvNewTianShenLvUpGoalVO:DoGoal()
	self:OpenFuncByClientParam();
end