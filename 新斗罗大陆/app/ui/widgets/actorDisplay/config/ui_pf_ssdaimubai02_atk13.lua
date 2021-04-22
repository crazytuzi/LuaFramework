local ui_pf_ssdaimubai02_atk13 = 
{
    CLASS = "composite.QUIDBParallel",
    ARGS =
    {
        {
            CLASS = "action.QUIDBPlayAnimation",
            OPTIONS = {animation = "attack13"},
        },
        {
			CLASS = "action.QUIDBPlayEffect",
			OPTIONS = {effect_id = "pf_ssdaimubai02_attack13_1_ui"},
		},
        {
            CLASS = "composite.QUIDBSequence",
            ARGS =
            {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 21 / 30 },
                },
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {effect_id = "pf_ssdaimubai02_attack13_2_ui"},
                },
            },
        },
    },
}

return ui_pf_ssdaimubai02_atk13