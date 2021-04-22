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
       -- {
       --     CLASS = "composite.QSBSequence",
         --   ARGS = 
           -- {
              --  {
                 --   CLASS = "action.QSBDelayTime",
                    --OPTIONS = {delay_frame = 15},
               -- },
               -- {
                 --   CLASS = "action.QSBPlayEffect",
                   -- OPTIONS = {effect_id = "pf02_ssqianshitangsan_attack13_2", is_hit_effect = false},
                --},
            --},
       -- },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {start_pos = {x = 200,y = 45},effect_id = "pf02_ssqianshitangsan_attack13_1", is_hit_effect = false},
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
                    OPTIONS = {target_random = true, start_pos = {x = 125,y = 40}, effect_id = "pf02_ssqianshitangsan_attack13_3", speed = 1500, hit_effect_id = "pf02_ssqianshitangsan_attack13_2"},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 48},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {target_random = true, start_pos = {x = 125,y = 47}, effect_id = "pf02_ssqianshitangsan_attack13_3", speed = 1500, hit_effect_id = "pf02_ssqianshitangsan_attack13_2"},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 51},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {target_random = true, start_pos = {x = 125,y = 54}, effect_id = "pf02_ssqianshitangsan_attack13_3", speed = 1500, hit_effect_id = "pf02_ssqianshitangsan_attack13_2"},
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
                    OPTIONS = {target_random = true, start_pos = {x = 125,y = 60}, effect_id = "pf02_ssqianshitangsan_attack13_3", speed = 1500, hit_effect_id = "pf02_ssqianshitangsan_attack13_2"},
                },
            },
        },
    },
}

return ssqianshitangsan_pugong2