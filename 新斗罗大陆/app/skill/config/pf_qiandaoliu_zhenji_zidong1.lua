
local pf_qiandaoliu_zhenji_zidong1 = 
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
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_qiandaoliu_attack13_1", is_hit_effect = false},
                },         
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.33},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_qiandaoliu_attack13_3", is_hit_effect = true},
                },         
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.33},
                },              
                {
                    CLASS = "action.QSBHitTarget",
                },               
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.33},
                },              
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "qiandaoliu_zhenji_zidong1", is_target = false},
                },              
            },
        },
    },
}

return pf_qiandaoliu_zhenji_zidong1