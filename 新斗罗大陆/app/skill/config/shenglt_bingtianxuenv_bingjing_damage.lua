-- 技能 冰晶持续AOE
-- 技能ID 53320
-- AOE
--[[
	冰天雪女
	升灵台
	ID:4126
	psf 2020-4-13
]]--

local shenglt_bingtianxuenv_bingjing_damage = {
    CLASS = "composite.QSBSequence",
    ARGS = {   
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai",no_cancel = true},
		},
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
				{
					CLASS = "action.QSBPlayAnimation",
					OPTIONS = {animation = "attack_21",no_stand = true},
				},
				{
					CLASS = "composite.QSBSequence",
					ARGS = {
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.6},
						},
						{
							CLASS = "composite.QSBParallel",
							ARGS = {
								{
									CLASS = "action.QSBPlayLoopEffect",
									OPTIONS = {effect_id = "honghuan_3_05", is_hit_effect = false, follow_actor_animation = true},
								},
								{
									CLASS = "action.QSBPlayLoopEffect",
									OPTIONS = {effect_id = "shuibinger_attack12_3", is_hit_effect = false, follow_actor_animation = true},
								},
								{
									CLASS = "action.QSBHitTimer",
								},
							},
						},
					},
				},
            },
        },

        {
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
					CLASS = "action.QSBStopLoopEffect",
						OPTIONS = {effect_id = "shuibinger_attack12_3"},
				},
				{
					CLASS = "action.QSBStopLoopEffect",
						OPTIONS = {effect_id = "honghuan_3_05"},
				},
                {
                    CLASS = "action.QSBActorStand",
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return shenglt_bingtianxuenv_bingjing_damage