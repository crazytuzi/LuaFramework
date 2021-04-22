local boss_niumang_shuilao = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "composite.QSBParallel",
            ARGS =
            {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "action.QSBPlaySound"
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 26 / 30},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "tianqingniumang_attack14_7" ,is_hit_effect = false},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS =
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 15 / 24 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS =
                            {
                                {
                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "niumang_shuiyux"} ,
                                },
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBArgsPosition",
                                            OPTIONS = {is_attackee = true},
                                        },
                                        {
                                            CLASS = "action.QSBDelayTime",
                                            OPTIONS = {delay_time = 72 / 24 ,pass_key = {"pos"}},
                                        },
                                        {
                                            CLASS = "action.QSBMultipleTrap",
                                            OPTIONS = {trapId = "niumang_shuizhux",count = 1},
                                        },
                                    },
                                },
                                {
                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                    OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "shuilao_hongquan"} ,
                                },
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

return boss_niumang_shuilao