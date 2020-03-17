--[[
卓越觉醒类任务目标
haohu
2015年5月15日22:14:02
]]

_G.SuperAwakenGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function SuperAwakenGoalVO:GetType()
	return QuestConsts.GoalType_SuperAwaken
end

--执行目标指引
function SuperAwakenGoalVO:DoGoal()
	FuncManager:OpenFunc( FuncConsts.EquipSuper )
end