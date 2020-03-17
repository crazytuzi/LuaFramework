--[[
通关副本类任务目标
haohu
2015年5月15日21:16:36
]]

_G.PassDungeonGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function PassDungeonGoalVO:GetType()
	return QuestConsts.GoalType_Dungeon;
end

--任务目标id,任务目标的第一个字段
function PassDungeonGoalVO:GetId()
	return tonumber( self.goalParam[1] );
end

--任务目标需要完成的总数量
function PassDungeonGoalVO:GetTotalCount()
	return tonumber( self.goalParam[2] ) or 0;
end

--执行目标指引
function PassDungeonGoalVO:DoGoal()
	local dungeonId = self:GetId()
	FuncManager:OpenFunc(FuncConsts.DominateRoute, false)
end