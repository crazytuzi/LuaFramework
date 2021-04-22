local ui_pf_ssdaimubai01_atk12 = 
{
    CLASS = "composite.QUIDBParallel",
    ARGS =
    {
        {
            CLASS = "composite.QUIDBSequence",
            ARGS =
            {
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "attack12"},
                },
            },
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS =
            {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 3 / 30 },
                },
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "pf_ssdaimubai01_attack12_1_ui"},
                },
            },
        },
    },
}

return ui_pf_ssdaimubai01_atk12