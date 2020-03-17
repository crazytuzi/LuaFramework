--[[
斗破苍穹层数达到
lizhuangzhuang
2015-10-5 21:01:38
]]

_G.BabelFloorGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function BabelFloorGoalVO:GetType()
	return QuestConsts.GoalType_BabelFloor;
end

function BabelFloorGoalVO:DoGoal()
	self:OpenFuncByClientParam();
end