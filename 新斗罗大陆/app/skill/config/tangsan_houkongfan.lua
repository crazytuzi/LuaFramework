local boss_zhaowuji_zhonglijiya = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "action.QSBRoledirection",
            OPTIONS = {direction = "right"},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack15_1"},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "tangsan_attack15_1_1", is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBCharge", --移动向目标位置（不打断动画）
                    OPTIONS = { pos = {x=580,y=320} , move_time = 1.1},
                },
            },
        },
        -- {
        --     CLASS = "action.QSBDelayTime",
        --     OPTIONS = {delay_time = 24 / 24 },
        -- },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack15_2"},
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBBullet",
                        },
                    },
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "tangsan_attack15_2_1", is_hit_effect = false},
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 6 },
                        },
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {effect_id = "tangsan_attack11_2_1", speed = 2500,start_pos = {x = -50,y = 180}},
                        },
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {effect_id = "tangsan_attack11_2_1", speed = 2500,start_pos = {x = -70,y = 80}},
                        },
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {effect_id = "tangsan_attack11_2_1", speed = 2500,start_pos = {x = -50,y = 98}},
                        },
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {effect_id = "tangsan_attack11_2_1", speed = 2500,start_pos = {x = -70,y = 135}},
                        },
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {effect_id = "tangsan_attack11_2_1", speed = 2500,start_pos = {x = -50,y = 118}},
                        },
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {effect_id = "tangsan_attack11_2_1", speed = 2500,start_pos = {x = -70,y = 165}},
                        },
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {effect_id = "tangsan_attack11_2_1", speed = 2500,start_pos = {x = -50,y = 143}},
                        },
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {effect_id = "tangsan_attack11_2_1", speed = 2500,start_pos = {x = -70,y = 126}},
                        },
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {effect_id = "tangsan_attack11_2_1", speed = 2500,start_pos = {x = -50,y = 172}},
                        },
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {effect_id = "tangsan_attack11_2_1", speed = 2500,start_pos = {x = -70,y = 164}},
                        },
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {effect_id = "tangsan_attack11_2_1", speed = 2500,start_pos = {x = -50,y = 180}},
                        },
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {effect_id = "tangsan_attack11_2_1", speed = 2500,start_pos = {x = -70,y = 80}},
                        },
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {effect_id = "tangsan_attack11_2_1", speed = 2500,start_pos = {x = -50,y = 98}},
                        },
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {effect_id = "tangsan_attack11_2_1", speed = 2500,start_pos = {x = -70,y = 135}},
                        },
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {effect_id = "tangsan_attack11_2_1", speed = 2500,start_pos = {x = -50,y = 118}},
                        },
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {effect_id = "tangsan_attack11_2_1", speed = 2500,start_pos = {x = -70,y = 165}},
                        },
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {effect_id = "tangsan_attack11_2_1", speed = 2500,start_pos = {x = -50,y = 143}},
                        },
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {effect_id = "tangsan_attack11_2_1", speed = 2500,start_pos = {x = -70,y = 126}},
                        },
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {effect_id = "tangsan_attack11_2_1", speed = 2500,start_pos = {x = -50,y = 172}},
                        },
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {effect_id = "tangsan_attack11_2_1", speed = 2500,start_pos = {x = -70,y = 164}},
                        },
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {effect_id = "tangsan_attack11_2_1", speed = 2500,start_pos = {x = -50,y = 180}},
                        },
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {effect_id = "tangsan_attack11_2_1", speed = 2500,start_pos = {x = -70,y = 80}},
                        },
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {effect_id = "tangsan_attack11_2_1", speed = 2500,start_pos = {x = -50,y = 98}},
                        },
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {effect_id = "tangsan_attack11_2_1", speed = 2500,start_pos = {x = -70,y = 135}},
                        },
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {effect_id = "tangsan_attack11_2_1", speed = 2500,start_pos = {x = -50,y = 118}},
                        },
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {effect_id = "tangsan_attack11_2_1", speed = 2500,start_pos = {x = -70,y = 165}},
                        },
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {effect_id = "tangsan_attack11_2_1", speed = 2500,start_pos = {x = -50,y = 143}},
                        },
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {effect_id = "tangsan_attack11_2_1", speed = 2500,start_pos = {x = -70,y = 126}},
                        },
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {effect_id = "tangsan_attack11_2_1", speed = 2500,start_pos = {x = -50,y = 172}},
                        },
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {effect_id = "tangsan_attack11_2_1", speed = 2500,start_pos = {x = -70,y = 164}},
                        },
                    },
                },
            },
        },  
        {
            CLASS = "action.QSBAttackFinish",
        },
    },

}

return boss_zhaowuji_zhonglijiya