
local dps = {
    -- CLASS = "action.QAIDPS",
    CLASS = "composite.QAISelector",
    ARGS = {
        {
            CLASS = "composite.QAISequence",
            ARGS = {
                {
                    CLASS = "action.QAIIsManualMode",
                },
                {
                    CLASS = "action.QAIReturnToAI",
                    OPTIONS = {hp_above_for_melee = 0.0, wait_time_for_melee = 2},
                },
            },
        },
        {
            CLASS = "action.QAIDPSARENA",
            OPTIONS = {target_order = {
                {actor_id = 1012, order = {4,3,2,1}},--柳二龙
				{actor_id = 1025, order = {4,3,2,1}},--小舞
                {actor_id = 1031, order = {4,3,2,1}},--白沉香
                {actor_id = 1033, order = {4,3,2,1}},--朱竹清
                {actor_id = 1049, order = {4,3,2,1}},--灵猫朱竹清
            }},
        },
    },
}

return dps
