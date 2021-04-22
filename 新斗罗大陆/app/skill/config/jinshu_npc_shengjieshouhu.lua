local shifa_tongyong = 
{
     CLASS = "composite.QSBParallel",
     ARGS = 
     {      
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_hit_effect = false},
        },
        {
             CLASS = "composite.QSBSequence",
             ARGS = 
             {  
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {  
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = true},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
            },
        },
    },
}

return shifa_tongyong