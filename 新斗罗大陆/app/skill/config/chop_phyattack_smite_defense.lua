
local chop_phyattack_smite_defense = {
   	CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack02"},
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
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 9},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
            },
        },
        {
    		CLASS = "composite.QSBSequence",
            ARGS = {
               {
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {is_hit_effect = false, effect_id = "shield_slam"},
				},
        	},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 0},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "shield_slam_y"},
                },
            },
        },
    },
}
return chop_phyattack_smite_defense