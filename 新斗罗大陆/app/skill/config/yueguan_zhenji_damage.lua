-- 技能 月关 异茸伤害
-- ID 190080
-- 真技强化前,菊花攻击异茸目标会触发该技能造成额外伤害.
--[[
	hero 月关
	ID:1018
	psf 2018-11-19
]]--

local yueguan_zhenji_damage = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        --真技效果
		{
			CLASS = "composite.QSBParallel",
			ARGS = {
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {is_hit_effect = false},
				},
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

return yueguan_zhenji_damage