
--[[
加入帮派
]]

_G.UnionPrayGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function UnionPrayGoalVO:GetType()
	return QuestConsts.GoalType_UnionPray;
end

function UnionPrayGoalVO:DoGoal()
	self:OpenFuncByClientParam();
end