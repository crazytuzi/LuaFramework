--[[
仙阶达到等级
]]

_G.HuoYueDuLevelToGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function HuoYueDuLevelToGoalVO:GetType()
	return QuestConsts.GoalType_HuoYueDuLevelTo;
end

function HuoYueDuLevelToGoalVO:DoGoal()
	
end