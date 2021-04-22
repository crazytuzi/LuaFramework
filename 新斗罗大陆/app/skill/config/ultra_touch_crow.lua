
local ultra_touch_crow = {              -- 麦迪文乌鸦之触
	CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack13"},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "maidiwen_wuyazhichu_1"},
                },
            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
            	{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 30},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {effect_id = "maidiwen_pugong_2_3", speed = 2360, hit_effect_id = "maidiwen_pugong_3_2"},
                },
                {
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_frame = 3},
	            },
	            {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {effect_id = "maidiwen_pugong_2_5", speed = 2360},
                },
	            {
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_frame = 4},
	            },
	            {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {effect_id = "maidiwen_pugong_2_4", speed = 2360},
                },
            },
		},
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 10},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "maidiwen_pugong_y"},
                },
            },
        },
    },
}

return ultra_touch_crow