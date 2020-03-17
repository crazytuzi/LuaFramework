--[[
主宰子路次数类任务目标
haohu
2015年6月6日15:05:19
]]

_G.DominateRoadGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function DominateRoadGoalVO:GetType()
	return QuestConsts.GoalType_DominateRoad
end

--执行目标指引
function DominateRoadGoalVO:DoGoal()
	FuncManager:OpenFunc( FuncConsts.DominateRoute )
end