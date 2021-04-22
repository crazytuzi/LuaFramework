
local ultra_shadow_gun = {         -- 月影之枪,月之女祭司

    CLASS = "composite.QSBParallel",
    ARGS = {
        {       -- 动作
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBPlayAnimation",
                                    OPTIONS = {animation = "attack14"},
                                },
                                {
                                    CLASS = "action.QSBAttackFinish"
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
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "yuenv_qiang_1"},
                }, 
                
        	},
    	},
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "yuenv_qiang_1_1"},
                }, 
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 35},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {effect_id = "yuenv_qiang_2", speed = 3300, hit_effect_id = "yuenv_qiang_3", rail_number = 1, rail_inter_frame = 1, shake = {amplitude = 10, duration = 0.17, count = 3}},
                },
            },
        },
    },
}

return ultra_shadow_gun
