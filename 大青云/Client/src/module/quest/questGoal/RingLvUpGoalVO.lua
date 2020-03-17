--[[
    Created by IntelliJ IDEA.
    戒指等级达到
    User: Hongbin Yang
    Date: 2016/8/22
    Time: 18:43
   ]]

_G.RingLvUpGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function RingLvUpGoalVO:GetType()
	return QuestConsts.GoalType_RingLvUp;
end

function RingLvUpGoalVO:DoGoal()
end

function RingLvUpGoalVO:GetTreeDataCount()
	return "";
end