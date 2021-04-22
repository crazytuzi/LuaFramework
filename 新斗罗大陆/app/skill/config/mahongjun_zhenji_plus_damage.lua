-- 技能 灼烧引爆
-- ID 190107
-- 目标被点燃就爆
--[[
	马红俊
	ID:1016
	psf 2018-11-20
]]--
local mahongjun_zhenji_plus_damage = {
     CLASS = "composite.QSBSequence",
     ARGS = {
		{
			CLASS = "action.QSBArgsIsUnderStatus",
			OPTIONS = {is_attacker = true,status = "ignited"},
		},
		{
			CLASS = "composite.QSBSelector",
			ARGS = {
				{
					CLASS = "composite.QSBSequence",
					ARGS = {
						{
							CLASS = "action.QSBPlaySound",
						},        
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBHitTarget",
						},
						{
							CLASS = "action.QSBAttackFinish",
						},
					},
				},
				{
					CLASS = "composite.QSBSequence",
					ARGS = {
						{
							CLASS = "action.QSBAttackFinish",
						},
					},
				},
			},
		},
    },
}

return mahongjun_zhenji_plus_damage