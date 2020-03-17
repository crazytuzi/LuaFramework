
--[[
加入帮派
]]

_G.LvNewTianShenUpStarGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function LvNewTianShenUpStarGoalVO:GetType()
	return QuestConsts.GoalType_NewTianShenUpStar;
end

function LvNewTianShenUpStarGoalVO:DoGoal()
	self:OpenFuncByClientParam();
end