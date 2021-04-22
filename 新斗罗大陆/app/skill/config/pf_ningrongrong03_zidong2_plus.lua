
local pf_ningrongrong03_zidong2_plus = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound",
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
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 5},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_ningrongrong03_attack14_1", is_hit_effect = false},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 0},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_ningrongrong03_attack14_1_1", is_hit_effect = false},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 35},
                },               
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {  
                        {
                            CLASS = "action.QSBActorStatus",
                            OPTIONS = 
                            {
                                { "target:hp_percent<0.33","target:apply_buff:pf_ningrongrong03_zidong2_plus_buff;y","under_status"},
                            }
                        },
                        {
                            CLASS = "action.QSBActorStatus",
                            OPTIONS = 
                            {
                                { "target:hp_percent<0.33","target:apply_buff:pf_ningrongrong03_zidong2_buff;y","not_under_status"},
                            }
                        },
                    },
                },
            },
        },
    },
}

return pf_ningrongrong03_zidong2_plus
