--[[
装备炼化类任务目标
haohu
2015年6月2日19:45:44
]]

_G.EquipRefinGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function EquipRefinGoalVO:GetType()
	return QuestConsts.GoalType_EquipRefin
end

--执行目标指引
function EquipRefinGoalVO:DoGoal()
	FuncManager:OpenFunc( FuncConsts.EquipRefin )
end