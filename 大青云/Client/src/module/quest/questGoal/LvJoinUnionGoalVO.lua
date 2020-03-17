
--[[
加入帮派
]]

_G.JoinUnionGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function JoinUnionGoalVO:GetType()
	return QuestConsts.GoalType_JoinUnion;
end

function JoinUnionGoalVO:DoGoal()
	self:OpenFuncByClientParam();
end