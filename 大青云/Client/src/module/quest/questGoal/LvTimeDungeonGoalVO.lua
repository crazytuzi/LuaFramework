--[[
参加灵光界类任务目标
haohu
2015年5月15日21:37:49
]]

_G.TimeDungeonGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function TimeDungeonGoalVO:GetType()
	return QuestConsts.GoalType_TimeDugeon
end

--执行目标指引
function TimeDungeonGoalVO:DoGoal()
	FuncManager:OpenFunc( FuncConsts.TimeDugeon )
end