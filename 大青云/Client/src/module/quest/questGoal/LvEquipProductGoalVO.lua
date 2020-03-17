--[[
装备升品类任务目标
haohu
2015年5月15日17:55:13
]]

_G.EquipProductGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function EquipProductGoalVO:GetType()
	return QuestConsts.GoalType_EquipPro;
end

--执行目标指引
function EquipProductGoalVO:DoGoal()
	FuncManager:OpenFunc( FuncConsts.EquipProduct )
end