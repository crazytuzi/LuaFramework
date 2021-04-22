
local acid_operation = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "acid_operation"},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBAttackFinish"
                        },
                    },
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
                    CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 40},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 40},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 40},
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
                    CLASS = "action.QSBDelayByAttack",
                },
                {
                    CLASS = "action.QSBPlayLoopEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "acid_operation_1"},
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 120},
                },
                {
                    CLASS = "action.QSBStopLoopEffect",
                },
        	},
    	},
    },
}

return acid_operation
