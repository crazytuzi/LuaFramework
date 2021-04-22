local zidan_tongyong = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "action.QSBPlayMountSkillAnimation",
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "mingyueye_debuff1_2", is_hit_effect = true},
        },
        {
            CLASS = "action.QSBHitTarget",                                                                                    
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return zidan_tongyong