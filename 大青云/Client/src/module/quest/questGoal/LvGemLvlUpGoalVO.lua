--[[
宝石升级类任务目标
haohu
2015年5月15日22:15:25
]]

_G.GemLvlUpGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function GemLvlUpGoalVO:GetType()
	return QuestConsts.GoalType_GemLvlUp
end

--执行目标指引
function GemLvlUpGoalVO:DoGoal()
	FuncManager:OpenFunc( FuncConsts.EquipGem )
end