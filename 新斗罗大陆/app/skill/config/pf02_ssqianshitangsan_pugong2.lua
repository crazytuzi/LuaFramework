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
                    OPTIONS = {delay_frame = 23},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {start_pos = {x = 160,y = 60}, effect_id = "pf02_ssqianshitangsan_attack01_2", speed = 1500, hit_effect_id = "pf02_ssqianshitangsan_attack01_3"},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 26},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {start_pos = {x = 160,y = 60}, effect_id = "pf02_ssqianshitangsan_attack12_3", speed = 1500, hit_effect_id = "pf02_ssqianshitangsan_attack01_3"},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 29},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {start_pos = {x =160,y = 60}, effect_id = "pf02_ssqianshitangsan_zhenji_1", speed = 1500, hit_effect_id = "pf02_ssqianshitangsan_attack01_3"},
                },
            },
        },
    },
}

return ssqianshitangsan_pugong2