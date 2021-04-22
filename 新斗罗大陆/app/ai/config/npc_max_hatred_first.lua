
local npc_max_hatred_first = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        {
            CLASS = "action.QAIIsHaveTarget",
        },
        {
            CLASS = "action.QAIAttackByHatred",
            OPTIONS = {is_get_max = true},
        },
    },
}

return npc_max_hatred_first