local xiaotianshixianjing = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_hit_effect = false},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlaySound",
                        },
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack21"},
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {

                                {   
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = {is_attacker = true},
                                },
                                {

                                {
                                    CLASS = "action.QSBTrap", 
                                    OPTIONS = {interval_time = 0.3, attacker_face = false,attacker_underfoot = true,count = 1, distance = 240, trapId = "xunlian_qianrenxue_xiaotianshi_xianjing03"},
                                },
                            },
                        },
                    },
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
    },
}

return xiaotianshixianjing