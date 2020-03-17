--[[
装备升星
]]

_G.XingtuStarGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function XingtuStarGoalVO:GetType()
	return QuestConsts.GoalType_XingtuStar;
end

function XingtuStarGoalVO:DoGoal()
	self:OpenFuncByClientParam();
end