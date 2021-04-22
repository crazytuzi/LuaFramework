-- 技能 冰天雪女大招
-- 技能ID 53317
--[[
	翠魔鸟王 4125
	升灵台
	psf 2020-4-13
]]--

local shenglt_bingtianxuenv_dazhao = {
    CLASS = "composite.QSBParallel",
    ARGS = {
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
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
                    OPTIONS = {delay_frame = 5},
                },
                {
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {--[[effect_id = "bingtianxuenv_attack11_1",]] is_hit_effect = false, haste = true},
				},
            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 41},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlaySceneEffect",
                            OPTIONS = {effect_id = "bingtianxuenv_attack11_3", pos = {x = 600,y = 300}}
                        },
						{
							CLASS = "composite.QSBSequence",
							ARGS = {
								{
									CLASS = "action.QSBArgsConditionSelector",
									OPTIONS = {
										failed_select = 4,
										{expression = "target:buff_num:hl_bingtianxuenv_pugong_debuff=1", select = 1},
										{expression = "target:buff_num:hl_bingtianxuenv_pugong_debuff=2", select = 2},
										{expression = "target:buff_num:hl_bingtianxuenv_pugong_debuff=3", select = 3},
									}
								},
								{
									CLASS = "composite.QSBSelector",
									ARGS = {
										{
											CLASS = "action.QSBHitTarget",
											OPTIONS = {property_promotion = { critical_chance = 0.2,critical_damage = 0.2 }},
										},
										{
											CLASS = "action.QSBHitTarget",
											OPTIONS = {property_promotion = { critical_chance = 0.4,critical_damage = 0.4 }},
										},
										{
											CLASS = "action.QSBHitTarget",
											OPTIONS = {property_promotion = { critical_chance = 0.6,critical_damage = 0.6 }},
										},
									},
								},
							},
						},
						{
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {all_enemy = true, buff_id = "hl_bingtianxuenv_dazhao_trigger_debuff_1"},
						},
						
                    },
                },
            },
        },
    },
}

return shenglt_bingtianxuenv_dazhao