--[[
    Created by IntelliJ IDEA.
    x个星图达到9重
    User: Hongbin Yang
    Date: 2016/9/3
    Time: 15:39
   ]]


_G.XingTuTo9GoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} )

function XingTuTo9GoalVO:GetType()
	return QuestConsts.GoalType_XingTuXTo9;
end

function XingTuTo9GoalVO:DoGoal()
	self:OpenFuncByClientParam();
end