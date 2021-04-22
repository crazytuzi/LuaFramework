-- 技能 翠魔鸟王普攻
-- 技能ID 30014
-- 噬脑：攻击敌方目标，并吸取该次攻击伤害50%的生命，治疗血量最低的友方魂师。同时补充治疗量250%的翠魔图腾储量。
--[[
	hunling 翠魔鸟王
	ID:2010
	psf 2019-10-8
]]--

local boss_cuimoniaowang_tuteng1 =  {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBHitTarget",
        },
		{
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return boss_cuimoniaowang_tuteng1