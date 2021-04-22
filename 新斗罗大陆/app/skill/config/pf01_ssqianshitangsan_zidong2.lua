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
                    OPTIONS = {delay_frame = 15},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf01_ssqianshitangsan_attack13_2", is_hit_effect = false},
                },
  
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {

                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 20},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf01_ssqianshitangsan_attack13_1", is_hit_effect = false},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 45},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {target_random = true, start_pos = {x = 100,y = 100}, effect_id = "pf01_ssqianshitangsan_attack13_3", speed = 1500, hit_effect_id = "pf01_ssqianshitangsan_attack12_2"},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 50},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {target_random = true, start_pos = {x = 100,y = 100}, effect_id = "pf01_ssqianshitangsan_attack13_3", speed = 1500, hit_effect_id = "pf01_ssqianshitangsan_attack12_2"},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 55},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {target_random = true, start_pos = {x = 100,y = 100}, effect_id = "pf01_ssqianshitangsan_attack13_3", speed = 1500, hit_effect_id = "pf01_ssqianshitangsan_attack12_2"},
                },
            },
        },
    },
}

return ssqianshitangsan_pugong2