-- 技能 天龙马大招
-- 技能ID 53293
-- 召唤天雷对单体目标造成攻击235%的魔法伤害，并传导闪电攻击所有带有“静电”标记的敌方，造成攻击150%的无视魔防的魔法伤害。
-- 天龙马还将吸收所有敌方目标的“静电”标记，每个标记回复15%能量并提升5%攻击18秒。
--[[
	hunling 天龙马
	ID:4108
	升灵台
	psf 2020-4-13
]]--

local shenglt_tianlongma_dazhao = {
    CLASS = "composite.QSBParallel",
    ARGS = {
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 15},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {--[[effect_id = "tianlongma_attack11_1",]] is_hit_effect = false, haste = true},
                },
            },
        },
		{
			CLASS = "action.QSBPlayAnimation",
		},
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 104},
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
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 73},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
							CLASS = "action.QSBHitTarget",
						},
						{
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = { is_hit_effect = true},
                        },
                        {
                            CLASS = "action.QSBSummonGhosts",
                            OPTIONS = {actor_id = 4109, life_span = 8,number = 1, no_fog = true, use_render_texture = false, 
                            percents = {attack = 1, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}},
                        },
                    },
                },
            },
        },
    },
}

return shenglt_tianlongma_dazhao