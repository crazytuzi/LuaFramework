
local npc_health = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        {
            CLASS = "action.QAITeleport",
            OPTIONS = {interval = 15.0, hp_less_than = 0.5},
        },
        {
            CLASS = "action.QAITreatTeammate",
            OPTIONS = {hp_below = 1, include_self = false, treat_hp_lowest = true},
        },
    },
}

return npc_health
