--[[
    Created by IntelliJ IDEA.
    
    User: Hongbin Yang
    Date: 2016/8/25
    Time: 20:45
   ]]


_G.DressEquipByNumQualityGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function DressEquipByNumQualityGoalVO:GetType()
	return QuestConsts.GoalType_DressEquipByNumQuality;
end

function DressEquipByNumQualityGoalVO:DoGoal()
	self:OpenFuncByClientParam();
end