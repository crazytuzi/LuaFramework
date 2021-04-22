-- 技能 冰天雪女大招
-- 技能ID 35046~50
-- 大寒无雪：全屏aoe形成巨大冰暴旋风攻击对手，有概率冰冻目标，每层冰锁会提升冰冻概率，
-- 暴击概率以及暴击伤害（1,2,3层冰冻概率提高15,30,50%，每层暴击率提升20%，爆伤提升100%）
--[[
	hunling 冰天雪女
	ID:2007 
	psf 2019-6-14
]]--

local hl_bingtianxuenv_dazhao = {
    CLASS = "composite.QSBParallel",
    ARGS = {
{
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},   --不会打断特效
            ARGS = 
            {
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.3, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 37},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = false},
                },
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                },

            },
        },
        {               --竞技场黑屏
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},   --不会打断特效
            ARGS = 
            {
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.3, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 37},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = false},
                },
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                },

            },
        },
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
											OPTIONS = {property_promotion = { critical_chance = 0.4,critical_damage = 0.2 }},
										},
										{
											CLASS = "action.QSBHitTarget",
											OPTIONS = {property_promotion = { critical_chance = 0.6,critical_damage = 0.2 }},
										},
									},
								},
							},
						},
						{
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {all_enemy = true, buff_id = "hl_bingtianxuenv_dazhao_trigger_debuff_3"},
						},
                    },
                },
            },
        },
    },
}

return hl_bingtianxuenv_dazhao