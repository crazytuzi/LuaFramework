
--[[
加入帮派
]]

_G.UnionAidGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function UnionAidGoalVO:GetType()
	return QuestConsts.GoalType_UnionAid;
end

function UnionAidGoalVO:DoGoal()
	self:OpenFuncByClientParam();
end