local sszhuzhuqing_sj = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                -- {
                --     CLASS = "action.QSBPlayEffect",
                --     OPTIONS = {is_hit_effect = false, effect_id = "sszzq_sj_cf1"},
                -- },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "sszzq_sj_cf2"},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "sszzq_sj_cf3"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {is_target = false, buff_id = "sszhuzhuqing_sj_cf4"}
                },
                {
                    CLASS = "action.QSBPlayGodSkillAnimation"
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {is_target = false, buff_id = "sszhuzhuqing_sj_cf"}
                },
                {
                    CLASS = "action.QSBSSZhuzhuQingCheckRange",
                    OPTIONS = 
                    {
                        revertable = true,
                        interval = 0.1, duration = 12,rect = {width = 525, height = 325},
                        tick_in_debuff_time = 0.6 ,
                        out_range_debuff_time = 13 ,
                        in_range_debuff_time = 13,
                        beattack_coefficient = - 0.36,
                        in_range_damage_scale = 1.2,
                        out_range_damage_scale = 0,
                        tick_inrange_damage_scale = 0,
                        tick_inrange_debuff_id = "sszhuzhuqing_sj1_youmming" ,
                        out_range_debuff_id = "sszhuzhuqing_sj4_stun",                  
                    },
                }, 
                {
                  CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },             
}

return sszhuzhuqing_sj