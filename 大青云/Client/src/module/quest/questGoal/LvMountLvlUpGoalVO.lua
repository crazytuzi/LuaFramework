--[[
升级坐骑类任务目标
haohu
2015年5月15日21:30:35
]]

_G.MountLvlUpGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function MountLvlUpGoalVO:GetType()
	return QuestConsts.GoalType_MountLvlUp
end

--执行目标指引
function MountLvlUpGoalVO:DoGoal()
	FuncManager:OpenFunc( FuncConsts.Horse )
end