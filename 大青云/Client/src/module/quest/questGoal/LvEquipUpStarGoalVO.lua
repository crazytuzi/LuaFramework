--[[
装备升星
]]

_G.EquipUpStarGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function EquipUpStarGoalVO:GetType()
	return QuestConsts.GoalType_EquipUpStar;
end

function EquipUpStarGoalVO:DoGoal()
	self:OpenFuncByClientParam();
end