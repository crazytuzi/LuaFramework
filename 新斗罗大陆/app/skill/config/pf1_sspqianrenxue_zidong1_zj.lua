
local tangsan_htc_zidong1 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
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
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 34},
                },
				{
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {

                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = false, effect_id = "pf1_sspqianrenxue_attack13_1"},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = false, effect_id = "pf1_sspqianrenxue_attack13_3"},
                        }, 
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = false, effect_id = "pf1_sspqianrenxue_attack13_5"},
                        },  
                        
                    },
                }, 	
                {
                    CLASS = "action.QSBHitTarget",
                    OPTIONS = {damage_scale = 2,check_target_by_skill = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5},
                },
                {
                    CLASS = "action.QSBHitTarget",
                    OPTIONS = {damage_scale = 2,check_target_by_skill = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5},
                },
                {
                    CLASS = "action.QSBHitTarget",
                    OPTIONS = {damage_scale = 2,check_target_by_skill = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5},
                },
                {
                    CLASS = "action.QSBHitTarget",
                    OPTIONS = {damage_scale = 2,check_target_by_skill = true},
                },       
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
				--技能抬手40帧
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 41},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf1_sspqianrenxue_zidong1_buff"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf1_sspqianrenxue_zidong1_buff2"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf1_sspqianrenxue_zidong1_gedang"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "pf1_sspqianrenxue_zidong1_gedang_zj"},
                },
            },
        },
    },
}
return tangsan_htc_zidong1