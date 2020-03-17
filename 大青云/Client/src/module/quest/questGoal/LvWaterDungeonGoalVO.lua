--[[
参加流水副本类任务目标
haohu
2015年6月26日19:28:03
]]

_G.WaterDungeonGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function WaterDungeonGoalVO:GetType()
	return QuestConsts.GoalType_WaterDugeon
end

--执行目标指引
function WaterDungeonGoalVO:DoGoal()
	FuncManager:OpenFunc( FuncConsts.LiuShui )
end