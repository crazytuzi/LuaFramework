--[[
充值达到
lizhuangzhuang
2015年12月21日21:58:56
]]

_G.ChargeToGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function ChargeToGoalVO:GetType()
	return QuestConsts.GoalType_ChargeTo;
end

function ChargeToGoalVO:DoGoal()
	Version:Charge();
end