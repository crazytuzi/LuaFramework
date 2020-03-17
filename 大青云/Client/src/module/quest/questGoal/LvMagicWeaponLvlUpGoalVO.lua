--[[
升级神兵类任务目标
haohu
2015年5月15日22:03:27
]]

_G.MagicWeaponLvlUpGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function MagicWeaponLvlUpGoalVO:GetType()
	return QuestConsts.GoalType_MagicWeaponLvlUp
end

--执行目标指引
function MagicWeaponLvlUpGoalVO:DoGoal()
	FuncManager:OpenFunc( FuncConsts.MagicWeapon )
end