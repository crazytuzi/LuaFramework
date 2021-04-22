local boss_daimubai_baihuliuxinyu = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "action.QSBPlaySound",
            OPTIONS = {sound_id ="daimubai_ready"},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayAnimation",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = true},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {       
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 16},
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                        },     
                    },
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}
return boss_daimubai_baihuliuxinyu