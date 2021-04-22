
local renmianmozhu_zibao_podun = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
        	CLASS = "composite.QSBParallel",
            ARGS =
            {
                {
                    CLASS = "action.QSBPlaySound"
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 37 / 24  },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBHitTarget",
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "renmianmozhu3_dead_3" , is_hit_effect = false },
                                },
                            },
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 37 / 24  },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                -- {
                                --   CLASS = "action.QSBPlayEffect",
                                --   OPTIONS = {is_hit_effect = false,effect_id = "zdb_atk11_3"},
                                -- },
                                {
                                    CLASS = "action.QSBTriggerSkill",
                                    OPTIONS = { skill_id = 51301 ,wait_finish = false},
                                },
                                -- {
                                --     CLASS = "action.QSBHitTarget",
                                -- },
                            },
                        },
                    },
                }, 
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return renmianmozhu_zibao_podun