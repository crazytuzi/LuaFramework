--[[
剥离卓越属性类任务目标
haohu
2015年5月15日21:19:59
]]

_G.SuperPeelGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function SuperPeelGoalVO:GetType()
	return QuestConsts.GoalType_SuperPeel
end

--执行目标指引
function SuperPeelGoalVO:DoGoal()
--	FuncManager:OpenFunc( FuncConsts.EquipSuperDown )
end