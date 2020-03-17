--[[
强化装备类任务目标
haohu
2015年5月14日20:35:29
]]

_G.StrengthenGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function StrengthenGoalVO:GetType()
	return QuestConsts.GoalType_Strengthen;
end

--执行目标指引
function StrengthenGoalVO:DoGoal()
	FuncManager:OpenFunc( FuncConsts.EquipStren )
end
