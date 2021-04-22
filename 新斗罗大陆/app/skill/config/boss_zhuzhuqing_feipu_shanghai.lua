-- 技能 鬼虎飞扑伤害
-- 扑向目标造成AOE伤害
--[[
	boss 朱竹青、朱竹青分身
	ID:3306\3307 副本3-16
	psf 2018-1-25
]]--

local boss_zhuzhuqing_feipu_shanghai = {
    CLASS = "composite.QSBSequence",
    ARGS = {
		{
			CLASS = "composite.QSBParallel",
			ARGS = {
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {is_hit_effect = true},
				},
				{
					CLASS = "action.QSBHitTarget",
				},
			},
		},
		{
			CLASS = "action.QSBAttackFinish"
		},
    },
}

return boss_zhuzhuqing_feipu_shanghai