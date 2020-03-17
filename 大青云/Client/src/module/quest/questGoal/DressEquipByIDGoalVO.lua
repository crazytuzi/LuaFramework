--[[
    Created by IntelliJ IDEA.
    
    User: Hongbin Yang
    Date: 2016/8/25
    Time: 20:45
   ]]


_G.DressEquipByIDGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function DressEquipByIDGoalVO:GetType()
	return QuestConsts.GoalType_DressEquipByID;
end

function DressEquipByIDGoalVO:DoGoal()
	self:OpenFuncByClientParam();
end