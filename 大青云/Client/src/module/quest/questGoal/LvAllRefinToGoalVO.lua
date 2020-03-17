--[[
全身强化等级达到
lizhuangzhuang
2015-10-5 20:54:26
]]

_G.AllRefinToGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function AllRefinToGoalVO:GetType()
	return QuestConsts.GoalType_AllRefinTo;
end

function AllRefinToGoalVO:DoGoal()
	FuncManager:OpenFunc( FuncConsts.EquipRefin )
end
