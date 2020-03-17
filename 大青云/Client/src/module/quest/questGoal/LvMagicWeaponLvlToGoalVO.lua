--[[
神兵阶数达到
lizhuangzhuang
2015-10-5 21:26:32
]]

_G.MagicWeaponLvlToGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function MagicWeaponLvlToGoalVO:GetType()
	return QuestConsts.GoalType_MagicWeaponLvlTo;
end

function MagicWeaponLvlToGoalVO:DoGoal()
	FuncManager:OpenFunc( FuncConsts.MagicWeapon )
end