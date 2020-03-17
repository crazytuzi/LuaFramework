
--[[
加入帮派
]]

_G.UnionDonationGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function UnionDonationGoalVO:GetType()
	return QuestConsts.GoalType_UnionDonation;
end

function UnionDonationGoalVO:DoGoal()
	self:OpenFuncByClientParam();
end