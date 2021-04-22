
local ultra_frost_nova = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_hit_effect = true, effect_id = "frost_nova_3"},
        },
        {
            CLASS = "action.QSBHitTarget",
        },
    },
}

return ultra_frost_nova