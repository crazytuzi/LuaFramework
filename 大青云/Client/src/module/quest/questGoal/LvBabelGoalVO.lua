--[[
参加斗破苍穹类任务目标
haohu
2015年5月15日21:37:49
]]

_G.BabelGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function BabelGoalVO:GetType()
	return QuestConsts.GoalType_Babel
end

--执行目标指引
function BabelGoalVO:DoGoal()
	self:OpenFuncByClientParam();
end