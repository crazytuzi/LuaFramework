local hl_qingyufenghuang_chuancheng3 = 
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
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "hl_qingyufenghuang_attack12_1_1"},
                },   
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "hl_qingyufenghuang_attack12_1_2"},
                },             
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 72},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {start_pos = {x = 130,y = 120},},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 60},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBArgsFindTargets",
                                    OPTIONS = {teammate = true, just_hero = true, no_support = true, select_name = "max_battle_force", select_num = 1},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {buff_id = {"hl_qingyufenghuang_chuancheng_hot_trigger_3"}},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBArgsFindTargets",
                                    OPTIONS = {teammate = true, just_hero = true, no_support = true, select_name = "max_battle_force", select_num = 1},
                                },

                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {buff_id = {"hl_qingyufenghuang_chuancheng_hot_remove_3"}},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBArgsFindTargets",
                                    OPTIONS = {teammate = true, just_hero = true, no_support = true, select_name = "max_battle_force", select_num = 1},
                                },

                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {buff_id = {"hl_qingyufenghuang_chuancheng_hot_3_remove"}},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBArgsFindTargets",
                                    OPTIONS = {teammate = true, just_hero = true, no_support = true, select_name = "max_battle_force", select_num = 1},
                                },

                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {buff_id = {"hl_qingyufenghuang_chuancheng_buff_trigger_3"}},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBArgsFindTargets",
                                    OPTIONS = {teammate = true, just_hero = true, no_support = true, select_name = "max_battle_force", select_num = 1},
                                },

                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {buff_id = {"hl_qingyufenghuang_chuancheng_buff_remove_3"}},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBArgsFindTargets",
                                    OPTIONS = {teammate = true, just_hero = true, no_support = true, select_name = "max_battle_force", select_num = 1},
                                },

                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {buff_id = {"hl_qingyufenghuang_chuancheng_buff_3_remove"}},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 1},
                                },
                                {
                                    CLASS = "action.QSBArgsFindTargets",
                                    OPTIONS = {teammate_and_self = true, just_hero = true, no_support = true},
                                },
                                {
                                    CLASS = "action.QSBDecreaseHpWtihoutLog",
                                    OPTIONS = {mode = "fixed_hp", value = 0, ignore_absorb = true}
                                },
                            },
                        },
                    },
                },
            },
        },
    },
}

return hl_qingyufenghuang_chuancheng3