--[[
    Created by IntelliJ IDEA.
    技能总等级达到
    User: Hongbin Yang
    Date: 2016/8/24
    Time: 18:16
   ]]


_G.SkillTotalLvlToGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function SkillTotalLvlToGoalVO:GetType()
	return QuestConsts.GoalType_SkillTotalLvTo;
end

function SkillTotalLvlToGoalVO:DoGoal()
	self:OpenFuncByClientParam();
end