
local lianzhu_fireball = {
	CLASS = "composite.QSBParallel",
    ARGS = {
        {
             CLASS = "composite.QSBSequence",
             ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
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
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false,effect_id = "lianzhu_fireball_1_1"},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 13},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false,effect_id = "lianzhu_fireball_1_2"},
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
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false,effect_id = "lianzhu_fireball_1_2"},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {effect_id = "lianzhu_fireball_2", speed = 2360, hit_effect_id = "lianzhu_fireball_3_1", start_pos = {x = -93, y = 107}, end_pos = {x = -30, y = 0}},
                },
                {
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_frame = 5},
	            },
	            {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {effect_id = "lianzhu_fireball_2", speed = 2360, hit_effect_id = "lianzhu_fireball_3_2", start_pos = {x = 0, y = 155}, end_pos = {x = 30, y = -35}},
                },
	            {
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_frame = 5},
	            },
	            {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {effect_id = "lianzhu_fireball_2", speed = 2360, hit_effect_id = "lianzhu_fireball_3_3", start_pos = {x = -40, y = 89}, end_pos = {x = 0, y = 30}},
                },
            },
		},
    },
}

return lianzhu_fireball