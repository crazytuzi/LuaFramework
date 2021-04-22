
local health = {
    CLASS = "composite.QAISelector",
    ARGS = {
        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 500,first_interval=0},
        --         },
        --         {
        --             CLASS = "action.QAIUseSkill",
        --             OPTIONS = {skill_id = 201103, trigger = true},
        --         },
        --     },
        -- },
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