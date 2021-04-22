
local the_position_ofthe_dust = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "the_dust"},
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayByAttack",
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.2},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                },
                            },
                        },
                    },
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 2},
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
                    CLASS = "action.QSBPlaySceneEffect",
                    OPTIONS = {effect_id = "the_position_ofthe_dust_1", pos  = {x = 650 , y = 200}},
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
                    CLASS = "action.QSBDragActor",
                    OPTIONS = {pos_type = "fix", pos  = {x = 650 , y = 200}, duration = 0.5},
                }, 
            },
        },
    },
}

return the_position_ofthe_dust
