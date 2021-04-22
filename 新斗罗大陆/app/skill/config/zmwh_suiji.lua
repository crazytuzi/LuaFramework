local zmwh_suiji = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBArgsRandom",
            OPTIONS = {
                input = {
                    datas = {
                        "zmwh_jiasu_trap",
                        "zmwh_zhiliao_trap",
                        "zmwh_jiansu_trap",
                    },
                },
                output = {output_type = "data"},
                args_translate = { select = "trapId"}
            },
        },
        {
            CLASS = "action.QSBTrap", 
            OPTIONS = 
            { 
                args = 
                {
                    {delay_time = 0 , pos = { x = 640, y = 410}} ,
                },
            },
        }, 
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
 }   

return zmwh_suiji
