
local pf_chengniantangsan02_zhenji_5 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlaySound",
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "tangsan_zhenji_1_die", is_target = false, probability=0.5},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 20},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_chengniantangsan02_daoguang_3", is_hit_effect = false},
                },                       
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 24},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_chengniantangsan02_attack14_4", is_hit_effect = false, ground_layer = true},
                },                    
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 24},
                },               
                {
                    CLASS = "action.QSBHitTarget",
                },                   
            },
        },
    },
}

return pf_chengniantangsan02_zhenji_5