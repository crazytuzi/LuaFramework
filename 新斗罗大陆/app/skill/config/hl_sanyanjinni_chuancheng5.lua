local hl_qingyufenghuang_chuancheng5 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    { 
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack12"},
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
                    OPTIONS = {delay_frame = 6},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "hl_sanyanjinni_attack12_1_1"},
                },   
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "hl_sanyanjinni_attack12_1_2"},
                },             
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                        {   
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 33},
                        },
                        {
                             CLASS = "composite.QSBSequence",
                             OPTIONS = {forward_mode = true},
                             ARGS = 
                             {
                                {
                                    CLASS = "action.QSBArgsSelectTarget",
                                    OPTIONS = {is_teammate=true,just_hero=true,lowest_hp=true,not_copy_hero=true}
                                },
                                {
                                    CLASS = "action.QSBArgsSelectTarget",
                                    OPTIONS = {is_teammate=true,just_hero=true,lowest_hp=true,not_copy_hero=true, args_translate = {selectTarget = "except_actor"}, pass_key = {"selectTarget", "except_actor"}}
                                },
                                {
                                    CLASS = "composite.QSBParallel",
                                    OPTIONS = {pass_key = {"selectTarget", "except_actor"}},
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBBullet",
                                            OPTIONS = {flip_follow_y = true,target_teammate_lowest_hp_percent=true,justHero=true,ignore_hit=true, start_pos = {x = 110,y = 90}},
                                        },
                                        {
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {buff_id = {"hl_sanyanjinni_chuancheng_buff_6"}},
                                        },
                                    }
                                },
                                {
                                    CLASS = "action.QSBArgsSelectTarget",
                                    OPTIONS = {is_teammate=true,just_hero=true,lowest_hp=true,not_copy_hero=true}
                                },
                                {
                                    CLASS = "composite.QSBParallel",
                                    OPTIONS = {pass_key = {"selectTarget"}},
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBBullet",
                                            OPTIONS = {flip_follow_y = true,target_teammate_lowest_hp_percent=true,justHero=true,ignore_hit=true, start_pos = {x = 110,y = 90}},
                                        },
                                        {
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {buff_id = {"hl_sanyanjinni_chuancheng_buff_6"},check_selectTarget = true},
                                        },
                                    }
                                },
                            },
                        },
                },
        },
    },
}

return hl_qingyufenghuang_chuancheng5