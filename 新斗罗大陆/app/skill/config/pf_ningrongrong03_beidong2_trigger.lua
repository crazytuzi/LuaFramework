
local pf_ningrongrong03_beidong2_trigger = 
{
     CLASS = "composite.QSBSequence",
     ARGS = 
     {
        {
            CLASS = "action.QSBPlaySound"
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
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return pf_ningrongrong03_beidong2_trigger