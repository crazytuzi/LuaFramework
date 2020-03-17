--[[
    Created by IntelliJ IDEA.
    经验副本
    User: Hongbin Yang
    Date: 2016/8/29
    Time: 11:59
   ]]

--[[
任务目标:经验副本
]]

_G.ExpDungeonGoalVO = setmetatable( {}, {__index = QuestGoalVO} )

function ExpDungeonGoalVO:GetType()
	return QuestConsts.GoalType_EXP_Dungeon;
end
function ExpDungeonGoalVO:CreateGoalParam()
	return nil;
end

function ExpDungeonGoalVO:CreateGuideParam()
	return nil;
end
function ExpDungeonGoalVO:DoGoal()
	FuncManager:OpenFunc(FuncConsts.experDungeon);
end