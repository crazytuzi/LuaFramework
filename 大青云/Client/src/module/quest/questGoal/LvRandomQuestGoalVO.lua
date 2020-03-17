--[[
完成奇遇次数
lizhuangzhuang
2015-10-5 20:56:51
]]

_G.RandomQuestGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function RandomQuestGoalVO:GetType()
	return QuestConsts.GoalType_RandomQuest;
end

function RandomQuestGoalVO:DoGoal()
	RandomQuestController:DoRandomQuest()
end