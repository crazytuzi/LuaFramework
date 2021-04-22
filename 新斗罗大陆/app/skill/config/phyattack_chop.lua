
local phyattack_chop = {
    CLASS = "composite.QSBParallel",
    ARGS = {
    	--[[ 
    		assembly line 1: 
    		1. play prepare animation
    		2. play skill animation
    		3. hit target, play hit effect and finish attack
    	--]]
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack01"},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBAttackFinish"
                        },
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
		},
	},
}

return phyattack_chop