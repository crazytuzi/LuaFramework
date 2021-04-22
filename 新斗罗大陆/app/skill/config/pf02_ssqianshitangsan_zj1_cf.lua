local ssmahongjun_dazhao =
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "action.QSBAttackFinish",
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
                 CLASS = "action.QSBPlayEffect",
                 OPTIONS = {effect_id = "pf02_ssqianshitangsan_zhenji_1_1", is_hit_effect = false},
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
                 OPTIONS = {effect_id = "pf02_ssqianshitangsan_zhenji_1_2", is_hit_effect = false},
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
                 CLASS = "action.QSBPlayEffect",
                 OPTIONS = {effect_id = "pf02_ssqianshitangsan_zhenji_1_2", is_hit_effect = false},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBArgsConditionSelector",
                    OPTIONS = 
                    {
                        failed_select = 2, --没有匹配到的话select会置成这个值 默认为2
                        {expression = "target:distance>300", select = 1},
                    }
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = 
                    {
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 8},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {
                                        start_pos = {x = -125,y = 100},
                                        effect_id = "pf02_ssqianshitangsan_zhenji_1", speed = 800, target_random = true,rail_number = 4, rail_delay = 0.07, length_threshold = 0,
                                        hit_effect_id = "pf02_ssqianshitangsan_zhenji_1_3", is_bezier = true, bullet_delay = 0.07, follow_target_pos = true,
                                        set_points = { 
                                            {{x = 160, y = 60},{x = 140, y = 60}}, 
                                        } 
                                    },
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 1},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {
                                        start_pos = {x = -125,y = 50},
                                        effect_id = "pf02_ssqianshitangsan_zhenji_2", speed = 800,target_random = true, rail_number = 2, rail_delay = 0.07, length_threshold = 0,
                                        hit_effect_id = "pf02_ssqianshitangsan_zhenji_1_3", is_bezier = true, bullet_delay = 0.07, follow_target_pos = true,
                                        set_points = { 
                                            {{x = 130, y = -180},{x = 170, y = -150}}, 
                                        } 
                                    },
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 1},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {
                                        start_pos = {x = -125,y = 100},
                                        effect_id = "pf02_ssqianshitangsan_zhenji_3", speed = 800, target_random = true,rail_number = 2, rail_delay = 0.07, length_threshold = 0,
                                        hit_effect_id = "pf02_ssqianshitangsan_zhenji_1_3", is_bezier = true, bullet_delay = 0.07, follow_target_pos = true,
                                        set_points = { 
                                            {{x = 160, y = 80},{x = 150, y = 80}},  
                                        } 
                                    },
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 1},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {
                                        start_pos = {x = -125,y = 50},
                                        effect_id = "pf02_ssqianshitangsan_zhenji_1", speed = 800, target_random = true,rail_number = 2, rail_delay = 0.07, length_threshold = 0,
                                        hit_effect_id = "pf02_ssqianshitangsan_zhenji_1_3", is_bezier = true, bullet_delay = 0.07, follow_target_pos = true,
                                        set_points = { 
                                            {{x = 200, y = -300},{x = 140, y = -150}}, 
                                        } 
                                    },
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 1},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {
                                        start_pos = {x = 125,y = 100},
                                        effect_id = "pf02_ssqianshitangsan_zhenji_2", speed = 800,target_random = true, rail_number = 2, rail_delay = 0.07, length_threshold = 0,
                                        hit_effect_id = "pf02_ssqianshitangsan_zhenji_1_3", is_bezier = true, bullet_delay = 0.07, follow_target_pos = true,
                                        set_points = { 
                                            {{x = 200, y = -300},{x = 160, y = -200}}, 
                                        } 
                                    },
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 8},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {
                                        start_pos = {x = -125,y = 100},
                                        effect_id = "pf02_ssqianshitangsan_zhenji_3", speed = 800, target_random = true,rail_number = 4, rail_delay = 0.07, 
                                        hit_effect_id = "pf02_ssqianshitangsan_zhenji_1_3" 
                                    },
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 1},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {
                                        start_pos = {x = -125,y = 50},
                                        effect_id = "pf02_ssqianshitangsan_zhenji_1", speed = 800,target_random = true, rail_number = 2, rail_delay = 0.07, 
                                        hit_effect_id = "pf02_ssqianshitangsan_zhenji_1_3" 
                                    },
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 1},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {
                                        start_pos = {x = -125,y = 100},
                                        effect_id = "pf02_ssqianshitangsan_zhenji_2", speed = 800,target_random = true, rail_number = 2, rail_delay = 0.07, 
                                        hit_effect_id = "pf02_ssqianshitangsan_zhenji_1_3"
                                    },
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 1},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {
                                        start_pos = {x = -125,y = 50},
                                        effect_id = "pf02_ssqianshitangsan_zhenji_3", speed = 800,target_random = true, rail_number = 2, rail_delay = 0.07, 
                                        hit_effect_id = "pf02_ssqianshitangsan_zhenji_1_3" 
                                    },
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 1},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = 
                                    {
                                        start_pos = {x = -125,y = 100},
                                        effect_id = "pf02_ssqianshitangsan_zhenji_1", speed = 800, target_random = true,rail_number = 2, rail_delay = 0.07, 
                                        hit_effect_id = "pf02_ssqianshitangsan_zhenji_1_3" 
                                    },
                                },
                            },
                        },
                    },
                },   
            },
        },  
    },
}

return ssmahongjun_dazhao