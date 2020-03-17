
--[[
获取法宝
]]

_G.GetFabaoGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function GetFabaoGoalVO:GetType()
	return QuestConsts.GoalType_GetFabao;
end

function GetFabaoGoalVO:DoGoal()
	
end