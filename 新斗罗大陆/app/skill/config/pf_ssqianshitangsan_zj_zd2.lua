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
                    OPTIONS = {delay_frame = 0},
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
                    OPTIONS = {effect_id = "pf_ssqianshitangsan_attack13_1", is_hit_effect = false},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 45},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {target_random = true, start_pos = {x = 120,y = 100}, effect_id = "pf_ssqianshitangsan_attack01_2_2", speed = 1500, hit_effect_id = "pf_ssqianshitangsan_attack13_2"},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 49},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {target_random = true, start_pos = {x = 120,y = 100}, effect_id = "pf_ssqianshitangsan_attack01_2_2", speed = 1500, hit_effect_id = "pf_ssqianshitangsan_attack13_2"},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 53},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {target_random = true, start_pos = {x = 120,y = 100}, effect_id = "pf_ssqianshitangsan_attack01_2_2", speed = 1500, hit_effect_id = "pf_ssqianshitangsan_attack13_2"},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 57},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {target_random = true, start_pos = {x = 120,y = 100}, effect_id = "pf_ssqianshitangsan_attack01_2_2", speed = 1500, hit_effect_id = "pf_ssqianshitangsan_attack13_2"},
                },
            },
        },
    },
}

return ssqianshitangsan_pugong2