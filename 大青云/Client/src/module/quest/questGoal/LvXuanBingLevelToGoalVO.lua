--[[
玄兵等级
]]

_G.XuanBingLevelToGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function XuanBingLevelToGoalVO:GetType()
	return QuestConsts.GoalType_XuanBingLevelTo;
end

function XuanBingLevelToGoalVO:DoGoal()
	
end