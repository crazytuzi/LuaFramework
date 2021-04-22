-- 技能 暗金恐爪熊大招
-- 技能ID 35031~35
-- 爪击：造成大量伤害，若目标身上有debuff，额外上BUFF
--[[
	hunling 暗金恐爪
	ID:2005 
	psf 2019-6-14
]]--

local boss_anjkzx_dazhao = {
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
                    OPTIONS = {delay_frame = 7},
                },
                {
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "kongzhuaxiong_attack11_1", is_hit_effect = false, haste = true},
				},
            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 32},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                    	{
							CLASS = "composite.QSBSequence",
							ARGS = {
								{
									CLASS = "action.QSBArgsIsUnderStatus",
									OPTIONS = {is_attackee = true, status = "shield"},
								},
								{
									CLASS = "composite.QSBSelector",
									ARGS = {
										{
											CLASS = "action.QSBHitTarget",
											OPTIONS = {property_promotion = { critical_chance = 1 }},
										},
										{
											CLASS = "action.QSBHitTarget",
										},
									},
								},
							},
						},
						{
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = { is_hit_effect = true},
                        },
                    },
                },
				{
					CLASS = "action.QSBArgsConditionSelector",
					OPTIONS = {
						failed_select = 5, --没有匹配到的话select会置成这个值 默认为2
						{expression = "target:buff_num:boss_anjkzx_pugong_debuff>3", select = 1},
						{expression = "target:buff_num:boss_anjkzx_pugong_debuff=3", select = 2},
						{expression = "target:buff_num:boss_anjkzx_pugong_debuff=2", select = 3},
						{expression = "target:buff_num:boss_anjkzx_pugong_debuff=1", select = 4},
						{expression = "target:buff_num:boss_anjkzx_pugong_debuff=0", select = 5},
					}
				},
				{
					CLASS = "composite.QSBSelector",
					ARGS = {
						{
							CLASS = "composite.QSBParallel",
							ARGS = {
								{
									CLASS = "action.QSBApplyBuff",
									OPTIONS = {is_target = true, buff_id = "boss_anjkzx_dazhao_debuff;y"},
								},
								{
									CLASS = "action.QSBApplyBuff",
									OPTIONS = {is_target = true, buff_id = "boss_anjkzx_dazhao_debuff;y"},
								},
								{
									CLASS = "action.QSBApplyBuff",
									OPTIONS = {is_target = true, buff_id = "boss_anjkzx_dazhao_debuff;y"},
								},
								{
									CLASS = "action.QSBApplyBuff",
									OPTIONS = {is_target = true, buff_id = "boss_anjkzx_dazhao_debuff;y"},
								},
							},
						},
						{
							CLASS = "composite.QSBParallel",
							ARGS = {
								{
									CLASS = "action.QSBApplyBuff",
									OPTIONS = {is_target = true, buff_id = "boss_anjkzx_dazhao_debuff;y"},
								},
								{
									CLASS = "action.QSBApplyBuff",
									OPTIONS = {is_target = true, buff_id = "boss_anjkzx_dazhao_debuff;y"},
								},
								{
									CLASS = "action.QSBApplyBuff",
									OPTIONS = {is_target = true, buff_id = "boss_anjkzx_dazhao_debuff;y"},
								},
							},
						},
						{
							CLASS = "composite.QSBParallel",
							ARGS = {
								{
									CLASS = "action.QSBApplyBuff",
									OPTIONS = {is_target = true, buff_id = "boss_anjkzx_dazhao_debuff;y"},
								},
								{
									CLASS = "action.QSBApplyBuff",
									OPTIONS = {is_target = true, buff_id = "boss_anjkzx_dazhao_debuff;y"},
								},
							},
						},
						{
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {is_target = true, buff_id = "boss_anjkzx_dazhao_debuff;y"},
						},
					},
				},
            },
        },
    },
}

return boss_anjkzx_dazhao