--[[
任务目标:单人副本
]]

_G.DungeonGoalVO = setmetatable( {}, {__index = QuestGoalVO} )

function DungeonGoalVO:GetType()
	return QuestConsts.GoalType_Dungeon;
end

function DungeonGoalVO:CreateGoalParam()
	return nil;
end

function DungeonGoalVO:CreateGuideParam()
	return nil;
end

function DungeonGoalVO:DoGoal()
	FuncManager:OpenFunc(FuncConsts.DominateRoute, false)
end

function DungeonGoalVO:GetLabelContent()
	local questCfg = self.questVO:GetCfg();
	return questCfg.unFinishLink;
end