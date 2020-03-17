--[[
人物等级
]]

_G.CharLevelToGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function CharLevelToGoalVO:GetType()
	return QuestConsts.GoalType_CharLevelTo;
end

function CharLevelToGoalVO:DoGoal()
	
end