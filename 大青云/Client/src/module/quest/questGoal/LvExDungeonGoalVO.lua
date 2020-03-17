--[[
参加极限挑战类任务目标
haohu
2015年5月18日16:57:59
]]

_G.ExDungeonGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function ExDungeonGoalVO:GetType()
	return QuestConsts.GoalType_ExDungeon
end

--执行目标指引
function ExDungeonGoalVO:DoGoal()
	FuncManager:OpenFunc( FuncConsts.ExDungeon )
end