--[[
任意技能等级达到 任意一个
lizhuangzhuang
2015-10-5 21:09:12
]]

_G.SkillLvlToGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function SkillLvlToGoalVO:GetType()
	return QuestConsts.GoalType_SkillLvlTo;
end

function SkillLvlToGoalVO:DoGoal()
	FuncManager:OpenFunc( FuncConsts.Skill )
end