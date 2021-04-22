local ssqianshitangsan_pugong1 = 
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
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "ssqianshitangsan_attack12_1", is_hit_effect = false},
				},
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 36},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {start_pos = {x = 125,y = 160}, effect_id = "ssqianshitangsan_attack01_2_2_1", speed = 1500, hit_effect_id = "ssqianshitangsan_attack01_2_4"},
                },
            },
        },
    },
}

return ssqianshitangsan_pugong1