
local npc_health_totem = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        {
            CLASS = "action.QAITreatTeammate",
            OPTIONS = {hp_below = 1, include_self = false, treat_hp_lowest = true},
        },
    },
}

return npc_health_totem
