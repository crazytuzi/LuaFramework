
local pf_chengniantangsan02_pugong2 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
			CLASS = "action.QSBPlaySound",
		},
		{
			CLASS = "action.QSBPlayAnimation",
		},           
		{
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 46},
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
                    OPTIONS = {delay_frame = 12},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_chengniantangsan01_attack02_1", is_hit_effect = false},
                },               
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 15},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_chengniantangsan01_attack01_3", is_hit_effect = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 14},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_chengniantangsan01_attack01_3", is_hit_effect = true},
                },               
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 15},
                },               
                {
                    CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 14},
                },               
                {
                    CLASS = "action.QSBHitTarget",
                },                    
            },
        },
    },
}

return pf_chengniantangsan02_pugong2