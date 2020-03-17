--[[
完成日环任务环数
lizhuangzhuang
2015-10-5 20:52:40
]]

_G.DailyTurnGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function DailyTurnGoalVO:GetType()
	return QuestConsts.GoalType_DailyTurn;
end

function DailyTurnGoalVO:DoGoal()

end