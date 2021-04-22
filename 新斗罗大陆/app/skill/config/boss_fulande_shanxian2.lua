
local boss_fulande_shanxian2 = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id="chuxian_lanse",is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBActorFadeOut",
                    OPTIONS = {duration = 0.3, revertable = true},
                },
            },
        },
        {
            CLASS = "action.QSBTeleportToAbsolutePosition",
            OPTIONS = {pos = {x = 1100, y = 200}},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id="chuxian_lanse",is_hit_effect = true},
                },
                {
                    CLASS = "action.QSBActorFadeIn",
                    OPTIONS = {duration = 0.3, revertable = true},
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return boss_fulande_shanxian2