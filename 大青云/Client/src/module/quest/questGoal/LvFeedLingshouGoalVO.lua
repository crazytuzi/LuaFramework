--[[
喂养灵兽类任务目标
haohu
2015年6月2日19:47:56
]]

_G.FeedLingshouGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function FeedLingshouGoalVO:GetType()
	return QuestConsts.GoalType_FeedLingshou
end

--执行目标指引
function FeedLingshouGoalVO:DoGoal()
	FuncManager:OpenFunc( FuncConsts.FaBao )
end