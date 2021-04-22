local pf_sszhuzhuqing02_sj3 = 
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
                --     OPTIONS = {is_hit_effect = false, effect_id = "pf_sszzq_sj_cf1"},
                -- },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "zzq_yypf_attack22_1_1"},
                },
                {
                    CLASS = "action.QSBPlayGodSkillAnimation"
                },
                -- {
                --     CLASS = "action.QSBPlayEffect",
                --     OPTIONS = {is_hit_effect = false, effect_id = "pf_sszzq_sj_cf3"},
                -- },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {is_target = false, buff_id = "pf_sszhuzhuqing02_sj_cf3"}
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {is_target = false, buff_id = "pf_sszhuzhuqing_sj_cf"}
                },
                {
                    CLASS = "action.QSBSSZhuzhuQingCheckRange",
                    OPTIONS = 
                    {
                        revertable = true,
                        interval = 0.1, duration = 12,rect = {width = 525, height = 325},
                        tick_in_debuff_time = 0.7 ,
                        out_range_debuff_time = 13 ,
                        in_range_debuff_time = 13,
                        beattack_coefficient = - 0.32,
                        in_range_damage_scale = 1.1,
                        out_range_damage_scale = 0,
                        tick_inrange_damage_scale = 0,
                        tick_inrange_debuff_id = "pf_sszhuzhuqing02_sj1_youmming" ,
                        out_range_debuff_id = "pf_sszhuzhuqing_sj3_stun",                  
                    },
                }, 
                {
                  CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },             
}

return pf_sszhuzhuqing02_sj3