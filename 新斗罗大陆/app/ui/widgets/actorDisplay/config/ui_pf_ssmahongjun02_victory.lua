
local ui_pf_ssmahongjun01_victory = 
{
    CLASS = "composite.QUIDBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QUIDBPlaySound"
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "victory"},
                },
            },
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 119},
                },
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "stand"},
                },
            },
        },
    },
}

return ui_pf_ssmahongjun01_victory