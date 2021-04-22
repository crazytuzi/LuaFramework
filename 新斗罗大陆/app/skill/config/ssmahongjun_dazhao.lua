-- 技能 ss马红俊大招
-- 技能ID 469
-- 顾名思义 魔法
--[[
    魂师 凤凰马红俊
    ID:1046 
    psf 2019-9-10
]]--

local ssmahongjun_dazhao = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.6, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 51},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = false},
                },
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                },
            },
        }, 
        {
            CLASS = "action.QSBPlaySound",
            -- OPTIONS = {sound_id ="bosaixi_skill"},
        },
        {                           --竞技场黑屏
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.6, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 51},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = false},
                },
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                },
            },
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai", is_target = false},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "ssmahongjun_dazhao_chuandi", is_target = true, no_cancel = true},
        },
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "action.QSBPlaySound",
            OPTIONS = {sound_id ="ssmahongjun_skill"},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
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
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 0},
                },
                {
                 CLASS = "action.QSBPlayEffect",
                 OPTIONS = {effect_id = "ssmahongjun_attack11_1", is_hit_effect = false},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 0},
                },
                {
                 CLASS = "action.QSBPlayEffect",
                 OPTIONS = {effect_id = "ssmahongjun_attack11_2", is_hit_effect = false},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBArgsConditionSelector",
                    OPTIONS = {
                        failed_select = 2, --没有匹配到的话select会置成这个值 默认为2
                        {expression = "target:distance>300", select = 1},
                    }
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = {
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 51},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {
                                        start_pos = {x = 125,y = 350},
                                        effect_id = "ssmahongjun_attack11_3", speed = 1800, rail_number = 4, rail_delay = 0.07, length_threshold = 0,
                                        hit_effect_id = "ssmahongjun_attack11_4", is_bezier = true, bullet_delay = 0.07, follow_target_pos = true,
                                        set_points = { 
                                            {{x = 160, y = 60},{x = 140, y = 60}}, 
                                        } 
                                    },
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {
                                        start_pos = {x = -35,y = 125},
                                        effect_id = "ssmahongjun_attack11_3", speed = 1800, rail_number = 2, rail_delay = 0.07, length_threshold = 0,
                                        hit_effect_id = "ssmahongjun_attack11_4", is_bezier = true, bullet_delay = 0.07, follow_target_pos = true,
                                        set_points = { 
                                            {{x = 130, y = -180},{x = 170, y = -150}}, 
                                        } 
                                    },
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {
                                        start_pos = {x = -35,y = 125},
                                        effect_id = "ssmahongjun_attack11_3", speed = 1800, rail_number = 2, rail_delay = 0.07, length_threshold = 0,
                                        hit_effect_id = "ssmahongjun_attack11_4", is_bezier = true, bullet_delay = 0.07, follow_target_pos = true,
                                        set_points = { 
                                            {{x = 160, y = 80},{x = 580, y = 350}},  
                                        } 
                                    },
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {
                                        start_pos = {x = -35,y = 125},
                                        effect_id = "ssmahongjun_attack11_3", speed = 1800, rail_number = 2, rail_delay = 0.07, length_threshold = 0,
                                        hit_effect_id = "ssmahongjun_attack11_4", is_bezier = true, bullet_delay = 0.07, follow_target_pos = true,
                                        set_points = { 
                                            {{x = 200, y = -300},{x = 500, y = 150}}, 
                                        } 
                                    },
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {
                                        start_pos = {x = 125,y = 350},
                                        effect_id = "ssmahongjun_attack11_3", speed = 1800, rail_number = 2, rail_delay = 0.07, length_threshold = 0,
                                        hit_effect_id = "ssmahongjun_attack11_4", is_bezier = true, bullet_delay = 0.07, follow_target_pos = true,
                                        set_points = { 
                                            {{x = 200, y = -300},{x = 300, y = -300}}, 
                                        } 
                                    },
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {
                                        start_pos = {x = 125,y = 350},
                                        effect_id = "ssmahongjun_attack11_3", speed = 1800, rail_number = 4, rail_delay = 0.07, length_threshold = 0,
                                        hit_effect_id = "ssmahongjun_attack11_4", is_bezier = true, bullet_delay = 0.07, follow_target_pos = true,
                                        set_points = { 
                                            {{x = 160, y = 60},{x = 300, y = -40}}, 
                                        } 
                                    },
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {
                                        start_pos = {x = -35,y = 125},
                                        effect_id = "ssmahongjun_attack11_3", speed = 1800, rail_number = 4, rail_delay = 0.07, length_threshold = 0,
                                        hit_effect_id = "ssmahongjun_attack11_4", is_bezier = true, bullet_delay = 0.07, follow_target_pos = true,
                                        set_points = { 
                                            {{x = 160, y = 60},{x = 300, y = -40}},  
                                        } 
                                    },
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {
                                        start_pos = {x = -35,y = 125},
                                        effect_id = "ssmahongjun_attack11_3", speed = 1800, rail_number = 2, rail_delay = 0.07, length_threshold = 0,
                                        hit_effect_id = "ssmahongjun_attack11_4", is_bezier = true, bullet_delay = 0.07, follow_target_pos = true,
                                        set_points = { 
                                            {{x = 160, y = 60},{x = 140, y = 60}}, 
                                        } 
                                    },
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {
                                        start_pos = {x = 20,y = 125},
                                        effect_id = "ssmahongjun_attack11_3", speed = 1800, rail_number = 2, rail_delay = 0.07, length_threshold = 0,
                                        hit_effect_id = "ssmahongjun_attack11_4", is_bezier = true, bullet_delay = 0.07, follow_target_pos = true,
                                        set_points = { 
                                            {{x = 150, y = 50},{x = 300, y = -50}}, 
                                        }
                                    },
                                },
                                {
                                    CLASS = "action.QSBRemoveBuff",
                                    OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai", is_target = false},
                                },
                                {
                                    CLASS = "action.QSBRemoveBuff",
                                    OPTIONS = {buff_id = "ssmahongjun_dazhao_chuandi", is_target = true},
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
                                    OPTIONS = {
                                        start_pos = {x = 125,y = 350},
                                        effect_id = "ssmahongjun_attack11_3", speed = 1800, rail_number = 4, rail_delay = 0.07, 
                                        hit_effect_id = "ssmahongjun_attack11_4" 
                                    },
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {
                                        start_pos = {x = -35,y = 125},
                                        effect_id = "ssmahongjun_attack11_3", speed = 1800, rail_number = 2, rail_delay = 0.07, 
                                        hit_effect_id = "ssmahongjun_attack11_4" 
                                    },
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {
                                        start_pos = {x = -35,y = 125},
                                        effect_id = "ssmahongjun_attack11_3", speed = 1800, rail_number = 2, rail_delay = 0.07, 
                                        hit_effect_id = "ssmahongjun_attack11_4"
                                    },
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {
                                        start_pos = {x = -35,y = 125},
                                        effect_id = "ssmahongjun_attack11_3", speed = 1800, rail_number = 2, rail_delay = 0.07, 
                                        hit_effect_id = "ssmahongjun_attack11_4" 
                                    },
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {
                                        start_pos = {x = 125,y = 350},
                                        effect_id = "ssmahongjun_attack11_3", speed = 1800, rail_number = 2, rail_delay = 0.07, 
                                        hit_effect_id = "ssmahongjun_attack11_4" 
                                    },
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {
                                        start_pos = {x = 125,y = 350},
                                        effect_id = "ssmahongjun_attack11_3", speed = 1800, rail_number = 4, rail_delay = 0.07, 
                                        hit_effect_id = "ssmahongjun_attack11_4" 
                                    },
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {
                                        start_pos = {x = -35,y = 125},
                                        effect_id = "ssmahongjun_attack11_3", speed = 1800, rail_number = 4, rail_delay = 0.07, 
                                        hit_effect_id = "ssmahongjun_attack11_4"
                                    },
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {
                                        start_pos = {x = -35,y = 125},
                                        effect_id = "ssmahongjun_attack11_3", speed = 1800, rail_number = 2, rail_delay = 0.07, 
                                        hit_effect_id = "ssmahongjun_attack11_4"
                                    },
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {
                                        start_pos = {x = 20,y = 125},
                                        effect_id = "ssmahongjun_attack11_3", speed = 1800, rail_number = 2, rail_delay = 0.07, 
                                        hit_effect_id = "ssmahongjun_attack11_4"
                                    },
                                },
                                {
                                    CLASS = "action.QSBRemoveBuff",
                                    OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai", is_target = false},
                                },
                                {
                                    CLASS = "action.QSBRemoveBuff",
                                    OPTIONS = {buff_id = "ssmahongjun_dazhao_chuandi", is_target = true},
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