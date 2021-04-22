local shifa_tongyong = 
{
     CLASS = "composite.QSBSequence",
     ARGS = 
    {     
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "sspqianrenxue_attack11_2", is_hit_effect = true},--龙特效
        },
        -- {
        --     CLASS = "action.QSBPlayAnimation",
        -- },
        {
            CLASS = "action.QSBHitTarget",
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return shifa_tongyong