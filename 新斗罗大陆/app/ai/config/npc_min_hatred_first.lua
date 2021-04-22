
local npc_min_hatred_first = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        {
            CLASS = "action.QAIIsHaveTarget",
        },
        {
            CLASS = "action.QAIAttackByHatred",
            OPTIONS = {is_get_max = false},
        },
    },
}

return npc_min_hatred_first