
local tianshuixueyuan_blizzard = {
    CLASS = "composite.QSBSequence",
    ARGS = {
            CLASS = "composite.QSBSequence",
            ARGS = 
		{
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack11"},
                        },
                },
            },
        },
    	{
            CLASS = "composite.QSBSequence",
            ARGS = {
               
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 2.3},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "dugubo_atk13_3", pos  = {x = 640 , y = 340}, ground_layer = true},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.15},
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "dugubo_atk13_3", pos  = {x = 640 , y = 340}, ground_layer = true},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.15},
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "dugubo_atk13_3", pos  = {x = 640 , y = 340}, ground_layer = true},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.15},
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "dugubo_atk13_3", pos  = {x = 640 , y = 340}, ground_layer = true},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.3},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                    OPTIONS = {is_range_hit = true},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.3},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                    OPTIONS = {is_range_hit = true},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.3},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                    OPTIONS = {is_range_hit = true},
                                },
                            },
                        },
                    },
                },
            },
        },
		{
            CLASS = "action.QSBAttackFinish"
        },
	},
}


return tianshuixueyuan_blizzard