--[[
装备打造次数类任务目标
haohu
2015年6月6日15:05:19
]]

_G.EquipBuildGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function EquipBuildGoalVO:GetType()
	return QuestConsts.GoalType_EquipBuild
end

--执行目标指引
function EquipBuildGoalVO:DoGoal()
	FuncManager:OpenFunc( FuncConsts.EquipBuild )
end