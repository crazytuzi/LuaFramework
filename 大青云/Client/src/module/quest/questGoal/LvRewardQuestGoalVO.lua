--[[
悬赏任务类任务目标
haohu
2015年5月15日21:30:35
]]

_G.RewardQuestGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function RewardQuestGoalVO:GetType()
	return QuestConsts.GoalType_RewardQuest
end

--执行目标指引
function RewardQuestGoalVO:DoGoal()
	FuncManager:OpenFunc( FuncConsts.FengYao )
end