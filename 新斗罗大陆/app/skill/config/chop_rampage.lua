
local chop_rampage = {
   	CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack01"},
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayByAttack",
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        -- {
                        --     CLASS = "action.QSBPlayEffect",
                        --     OPTIONS = {is_hit_effect = true},
                        -- },
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                    },
                },
            },
        },
        {
    		CLASS = "composite.QSBSequence",
            ARGS = {
                {
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {is_hit_effect = true, effect_id = "knock_1"},
				},
        	},
        }
    }
}
return chop_rampage