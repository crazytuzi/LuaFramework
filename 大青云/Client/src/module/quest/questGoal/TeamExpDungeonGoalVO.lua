--[[
任务目标:组队经验副本
]]

_G.TeamExpDungeonGoalVO = setmetatable( {}, {__index = QuestGoalVO} )

function TeamExpDungeonGoalVO:GetType()
	return QuestConsts.GoalType_Team_Exp_Dungeon;
end

function TeamExpDungeonGoalVO:CreateGoalParam()
	return nil;
end

function TeamExpDungeonGoalVO:CreateGuideParam()
	return nil;
end

function TeamExpDungeonGoalVO:DoGoal()
		FuncManager:OpenFunc(FuncConsts.teamExper);
end