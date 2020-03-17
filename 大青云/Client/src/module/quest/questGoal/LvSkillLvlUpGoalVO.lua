--[[
升级技能类任务目标
haohu
2015年5月15日22:13:00
]]

_G.SkillLvlUpGoalVO = setmetatable( {}, {__index = LevelQuestGoalVO} );

function SkillLvlUpGoalVO:GetType()
	return QuestConsts.GoalType_SkillLvlUp
end

--执行目标指引
function SkillLvlUpGoalVO:DoGoal()
	FuncManager:OpenFunc( FuncConsts.Skill )
end