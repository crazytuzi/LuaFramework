--[[
完成寻宝次数
lizhuangzhuang
2015-10-5 21:03:15
]]

_G.WaBaoTimesGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function WaBaoTimesGoalVO:GetType()
	return QuestConsts.GoalType_WaBaoTimes;
end

function WaBaoTimesGoalVO:DoGoal()
	WaBaoController:ShowUI();
end