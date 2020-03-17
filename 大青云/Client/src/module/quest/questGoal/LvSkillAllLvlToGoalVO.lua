--[[
全身技能等级达到 （目前是全身的最小等级）
lizhuangzhuang
2015-10-5 21:13:43
]]

_G.SkillAllLvlToGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function SkillAllLvlToGoalVO:GetType()
	return QuestConsts.GoalType_SkillAllLvlTo;
end

function SkillAllLvlToGoalVO:DoGoal()
	FuncManager:OpenFunc( FuncConsts.Skill )
end