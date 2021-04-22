-- 技能 翠魔鸟王普攻
-- 技能ID 30014
-- 噬脑：攻击敌方目标，并吸取该次攻击伤害50%的生命，治疗血量最低的友方魂师。同时补充治疗量250%的翠魔图腾储量。
--[[
	hunling 翠魔鸟王
	ID:2010
	psf 2019-10-8
]]--

local hl_cuimoniaowang_pugong1 =  {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
			CLASS = "action.QSBPlayAnimation",
		},
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 20},
                },
                {
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {is_hit_effect = false, haste = true},
				},
            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 22},
                },
				{
					CLASS = "action.QSBBullet",
					OPTIONS = {start_pos = {x = 50,y = 100}},
				},
            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 37},
                },
				{
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return hl_cuimoniaowang_pugong1