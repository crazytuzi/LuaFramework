local common_xiaoqiang_victory = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBUncancellable"
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBRoledirection",
                            OPTIONS = {direction = "right"},
                        },
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack22"},
                        },
                        {
                          CLASS = "action.QSBAttackFinish",
                        },
                    },
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {is_target = false, buff_id = "pf_ssaosika02_jxwd"}
                },
                -- {
                --   CLASS = "action.QSBHitTarget",
                -- },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0 / 30},
                        },
                        {
                            CLASS = "action.QSBActorFadeTo",
                            OPTIONS = {duration = 2, revertable = true ,opcity = 100 ,is_do_final = true},
                        },                 
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0/ 30 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = false, effect_id = "pf_ssaosika02_attack22_1"},
                                },
                                -- {
                                --     CLASS = "action.QSBPlayEffect",
                                --     OPTIONS = {is_hit_effect = false, effect_id = "pf_ssaosika02_attack22_2"},
                                -- },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = false, effect_id = "pf_ssaosika02_attack22_3"},
                                },
                            },
                        },
                    },
                },
            },
        },
    },
}

return common_xiaoqiang_victory