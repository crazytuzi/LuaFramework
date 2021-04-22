-- 技能 尘心合体技溅射伤害
-- 技能ID 225
-- 被合体技击中的目标会放这个技能给周围队友造成伤害,属性读的尘心的
--[[
	hero 尘心
	ID:1028 
	psf 2018-5-4
]]--

local chenxin_hetiji_trigger = {
    CLASS = "composite.QSBParallel",
    ARGS = {
		{
			CLASS = "action.QSBHitTarget",
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}

return chenxin_hetiji_trigger

