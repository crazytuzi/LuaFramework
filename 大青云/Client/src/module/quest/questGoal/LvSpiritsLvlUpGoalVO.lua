--[[
升级武魂类任务目标
haohu
2015年5月15日22:01:37
]]

_G.SpiritsLvlUpGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function SpiritsLvlUpGoalVO:GetType()
	return QuestConsts.GoalType_SpiritsLvlUp
end

--执行目标指引
function SpiritsLvlUpGoalVO:DoGoal()
	FuncManager:OpenFunc( FuncConsts.FaBao )
end