
local pf_chengniantangsan02_pugong1 = 
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
                    OPTIONS = {delay_frame = 22},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_chengniantangsan01_attack01_1", is_hit_effect = false},
                },         
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 25},
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
                    OPTIONS = {delay_frame = 25},
                },               
                {
                    CLASS = "action.QSBHitTarget",
                },               
            },
        },
    },
}

return pf_chengniantangsan02_pugong1