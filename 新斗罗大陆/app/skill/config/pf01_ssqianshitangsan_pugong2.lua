local ssqianshitangsan_pugong2 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 1},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {   
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 18},
                },
                {
					CLASS = "action.QSBPlayEffect",
					OPTIONS = { is_hit_effect = false},
				},
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 20},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {start_pos = {x = 200,y = 65}, effect_id = "pf01_ssqianshitangsan_attack01_2", speed = 1500, hit_effect_id = "pf01_ssqianshitangsan_attack01_3"},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 25},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {start_pos = {x = 200,y = 65}, effect_id = "pf01_ssqianshitangsan_attack01_2", speed = 1500, hit_effect_id = "pf01_ssqianshitangsan_attack01_3"},
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
                    OPTIONS = {start_pos = {x = 200,y = 65}, effect_id = "pf01_ssqianshitangsan_attack01_2", speed = 1500, hit_effect_id = "pf01_ssqianshitangsan_attack01_3"},
                },
            },
        },
    },
}

return ssqianshitangsan_pugong2