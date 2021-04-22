-- 技能 翠魔鸟王普攻返回治疗
-- 技能ID 31004
-- 噬脑：攻击敌方目标，并吸取该次攻击伤害50%的生命，治疗血量最低的友方魂师。同时补充治疗量250%的翠魔图腾储量。
--[[
	hunling 翠魔鸟王
	ID:2010
	psf 2019-10-8
]]--

local hl_cuimoniaowang_pugong2 = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
			CLASS = "action.QSBBullet",
			OPTIONS = {from_target = true, start_pos = {x = 0,y = 100},target_teammate_lowest_hp_percent = true,disable_change_target_with_behavior = true},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
    },
}

return hl_cuimoniaowang_pugong2