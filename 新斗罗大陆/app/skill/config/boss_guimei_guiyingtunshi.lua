

local boss_guimei_guiyingtunshi = {

	CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "action.QSBPlayAnimation",
        },
		{
			CLASS = "action.QSBPlayEffect",
			OPTIONS = {is_hit_effect = false, effect_id = "boss_guimei_attack14_1"},
		},
        {
             CLASS = "composite.QSBSequence",
             ARGS = {
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "guimei_jiguanqiang_yujingkuang"},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {is_tornado = true, tornado_size = {width = 150, height = 100}, start_pos = {x = 0, y = 65, is_animation = false}},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1/30},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {is_tornado = true, tornado_size = {width = 150, height = 100}, start_pos = {x = 0, y = -60, is_animation = false}},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1/30},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {is_tornado = true, tornado_size = {width = 150, height = 100}, start_pos = {x = 0, y = 20, is_animation = false}},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1/30},
                },                                              
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {is_tornado = true, tornado_size = {width = 150, height = 100}, start_pos = {x = 0, y = 5, is_animation = false}},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1/30},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {is_tornado = true, tornado_size = {width = 150, height = 100}, start_pos = {x = 0, y = 60, is_animation = false}},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1/30},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {is_tornado = true, tornado_size = {width = 150, height = 100}, start_pos = {x = 0, y = -35, is_animation = false}},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1/30},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {is_tornado = true, tornado_size = {width = 150, height = 100}, start_pos = {x = 0, y = 40, is_animation = false}},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1/30},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {is_tornado = true, tornado_size = {width = 150, height = 100}, start_pos = {x = 0, y = 20, is_animation = false}},
                },                     
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}



return boss_guimei_guiyingtunshi    