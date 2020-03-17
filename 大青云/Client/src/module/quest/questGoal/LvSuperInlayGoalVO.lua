--[[
卓越属性镶嵌类任务目标
haohu
2015年5月15日21:37:49
]]

_G.SuperInlayGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function SuperInlayGoalVO:GetType()
	return QuestConsts.GoalType_SuperInlay
end

--执行目标指引
function SuperInlayGoalVO:DoGoal()
	FuncManager:OpenFunc( FuncConsts.EquipSuperUp )
end