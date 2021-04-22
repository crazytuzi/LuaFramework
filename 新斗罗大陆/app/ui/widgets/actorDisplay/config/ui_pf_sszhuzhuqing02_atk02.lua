local ui_pf_sszhuzhuqing02_atk02 = 
{
    CLASS = "composite.QUIDBParallel",
    ARGS = 
    {
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 1 / 30},
                },
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "attack02"},
                },
            },
        },
        {
            CLASS = "action.QUIDBPlayEffect",
            OPTIONS = {effect_id = "ui_zzq_yypf_attack01_1_2"},
        },
        {
            CLASS = "action.QUIDBPlaySound",
        },
    },
}
return ui_pf_sszhuzhuqing02_atk02