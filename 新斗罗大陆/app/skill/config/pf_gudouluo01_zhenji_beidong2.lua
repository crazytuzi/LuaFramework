
local gudouluo_zhenji_beidong2 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    { 
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "pf_gudouluo01_attack1_1", is_hit_effect = false},
                        },
                    },
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {start_pos = {x = 125,y = 115}, effect_id = "pf_gudouluo01_attack1_2", speed = 1500, hit_effect_id = "pf_gudouluo01_attack1_3"},
                },
                {
                    CLASS = "action.QSBActorStatus",
                    OPTIONS = 
                    {
                       { "target:hp_percent<0.2","trigger_skill:290237"},
                    }
                },
            },
        },
    },
}

return gudouluo_zhenji_beidong2

