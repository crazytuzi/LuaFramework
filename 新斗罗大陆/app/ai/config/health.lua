
local health = {
    CLASS = "composite.QAISelector",
    ARGS = {
        {
            CLASS = "action.QAIEscape",
            OPTIONS = {distance = 2}
        },
        {
            CLASS = "composite.QAISelector",
            ARGS = {
                {
                    CLASS = "composite.QAISequence",
                    ARGS = {
                        {
                            CLASS = "action.QAIIsManualMode",
                        },
                        {
                            CLASS = "action.QAIIsHaveTarget",
                        },
                    },
                },
                {
                    CLASS = "action.QAIHEALTH",
                },
                {
                    CLASS = "action.QAITreatTeammate",
                    OPTIONS = {hp_below = 0.8, include_self = true, treat_hp_lowest = true}
                },
            },
        },
    },
}

return health