
--[[
人物等级
]]

_G.UseDanyaoTimesGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function UseDanyaoTimesGoalVO:GetType()
	return QuestConsts.GoalType_UseDanyaoTimes;
end

function UseDanyaoTimesGoalVO:DoGoal()
	
end