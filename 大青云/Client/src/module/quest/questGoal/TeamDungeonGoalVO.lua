--[[
任务目标:组队副本
]]

_G.TeamDungeonGoalVO = setmetatable( {}, {__index = QuestGoalVO} )

function TeamDungeonGoalVO:GetType()
	return QuestConsts.GoalType_Team_Dungeon;
end

function TeamDungeonGoalVO:CreateGoalParam()
	return nil;
end

function TeamDungeonGoalVO:CreateGuideParam()
	return nil;
end

function TeamDungeonGoalVO:DoGoal()
	FuncManager:OpenFunc(FuncConsts.teamDungeon);
end