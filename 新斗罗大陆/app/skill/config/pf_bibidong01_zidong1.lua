-- 技能 比比东自动1
-- 技能ID 396
-- 加护盾
--[[
	魂师 比比东
	ID:1026 
	psf 2019-7-8
]]--

local bibidong_zidong1 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
		{
			CLASS = "action.QSBActorStatus",
			OPTIONS = 
			{
			   { "target:hp_percent>0.5","target:remove_buff:bibidong_hp_lower_50"},
			}
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
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "pf_bibidong01_attack13_1_1", is_hit_effect = false},
				},
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 27},
                },
    --             {
				-- 	CLASS = "action.QSBPlayEffect",
				-- 	OPTIONS = {effect_id = "bibidong_attack13_1_2", is_hit_effect = false},
				-- },
            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 30},
                },
				{
					CLASS = "action.QSBArgsIsUnderStatus",
					OPTIONS = {is_attacker = true, status = "bibidong_siwang",},
				},
				{
					CLASS = "composite.QSBSelector",
					ARGS = {
						{
							CLASS = "composite.QSBSequence",
							ARGS = {
								{
									CLASS = "action.QSBApplyBuff",
									OPTIONS = {buff_id = "pf_bibidong01_zidong1_buff;y"},
								},
								{
									CLASS = "action.QSBApplyBuff",
									OPTIONS = {buff_id = "pf_bibidong01_zidong1_buff;y"},
								},
							},
						},
						{
							CLASS = "composite.QSBSequence",
							ARGS = {
								{
									CLASS = "action.QSBApplyBuff",
									OPTIONS = {buff_id = "pf_bibidong01_zidong1_buff;y"},
								},
								{
									CLASS = "action.QSBApplyBuffMultiple",	
									OPTIONS = {target_type = "teammate",buff_id = "bibidong_immune_zidong1_debuff"}
								},
								{
									CLASS = "action.QSBApplyBuffMultiple",	
									OPTIONS = {target_type = "teammate",buff_id = "pf_bibidong01_zidong1_buff;y"}
								},
							},
						},
					},
				},
				{
					CLASS = "action.QSBActorStatus",
					OPTIONS = 
					{
					   { "target:hp_percent<0.55","target:apply_buff:bibidong_hp_lower_50"},
					}
				},
            },
        },
    },
}

return bibidong_zidong1

