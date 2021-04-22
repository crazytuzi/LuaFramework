
local dps = {
    -- CLASS = "action.QAIDPS",
    CLASS = "composite.QAISelector",
    ARGS = {
    	-- {
     --        CLASS = "composite.QAISequence",
     --        ARGS = 
     --        {
     --            {
     --                CLASS = "action.QAITimer",
     --                OPTIONS = {interval = 500,first_interval=0},
     --            },
     --            {
     --                CLASS = "action.QAIUseSkill",
     --                OPTIONS = {skill_id = 201103, trigger = true},
     --            },
     --        },
     --    },
        {
            CLASS = "composite.QAISequence",
            ARGS = {
                {
                    CLASS = "action.QAIIsManualMode",
                },
                {
                    CLASS = "action.QAIReturnToAI",
                    OPTIONS = {hp_above_for_melee = 0.0, wait_time_for_melee = 0},
                },
            },
        },
        {
            CLASS = "action.QAIDPSMONSTER",
            OPTIONS = {target_order = {
                {actor_id = 10019, order = {4,3,2,1}},
                {actor_id = 10020, order = {4,3,2,1}},
                {actor_id = 10021, order = {4,3,2,1}},
            }},
        },
    },
}

return dps
