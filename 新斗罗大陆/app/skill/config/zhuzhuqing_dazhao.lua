
local zhuzhuqing_dazhao = {
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
                    OPTIONS = {delay_frame = 30},
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
            OPTIONS = {sound_id ="pf_zhuzhuqing01_skill"},
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
                    OPTIONS = {delay_frame = 30},
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
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 14},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_zhuzhuqing01_attack11_lizi", is_hit_effect = false, haste = true},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBStopMove",
                },
                {
                    CLASS = "action.QSBRoledirection",
                    OPTIONS = {direction ="target"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "mianyi_suoyou_shanghai", is_target = false},
                },
                {
                    CLASS = "action.QSBArgsNumber",
                    OPTIONS = {is_attacker = true, buff_stacks = true, stub_buff_id = "zhuzhuqing_canying"},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "zhuzhuqing_canying", is_target = false, remove_all_same_buff_id = true, pass_key = {"number"}},
                },
                {
                    CLASS = "composite.QSBSelectorByNumber",
                    ARGS = 
                    {
                        {
                            CLASS = "composite.QSBSequence",
                            OPTIONS = {flag = 0},
                            ARGS = {
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "action.QSBPlayEffect",
                                            OPTIONS = {effect_id = "pf_zhuzhuqing01_attack11_ready", is_hit_effect = false, haste = true},
                                        },
                                        {
                                            CLASS = "action.QSBPlayEffect",
                                            OPTIONS = {effect_id = "pf_zhuzhuqing01_attack11_jump", is_hit_effect = false, haste = true},
                                        },
                                        {
                                            CLASS = "action.QSBPlayAnimation",
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_frame = 15},
                                                },
                                                {
                                                    CLASS = "composite.QSBParallel", 
                                                    ARGS = {
                                                        {
                                                            CLASS = "action.QSBHitTarget",
                                                        },
                                                        {
                                                            CLASS = "action.QSBPlayEffect",
                                                            OPTIONS = { is_hit_effect = true},
                                                        },
                                                    },
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
                                                    CLASS = "action.QSBActorFadeOut",
                                                    OPTIONS = {duration = 0.05, revertable = true},
                                                },
                                                {
                                                    CLASS = "action.QSBTeleportToTargetPos",
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
                                                    CLASS = "action.QSBSummonGhosts",
                                                    OPTIONS = {
                                                        actor_id = 1041, life_span = 10,number = 1, no_fog = true,relative_pos = {x = 125, y = 0}, 
                                                        appear_skill = 364,--[[入场技能]]direction = "left",
                                                        percents = {attack = 0.8, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
                                                        extends_level_skills = {364}, same_target = true, clean_new_wave = true, is_no_deadAnimation = true
                                                    },
                                                },
                                            },
                                        },
                                        -- {
                                        --     CLASS = "composite.QSBSequence",
                                        --     ARGS = {
                                        --         {
                                        --             CLASS = "action.QSBDelayTime",
                                        --             OPTIONS = {delay_frame = 45},
                                        --         },
                                        --         {
                                        --             CLASS = "action.QSBSummonGhosts",
                                        --             OPTIONS = {
                                        --                 actor_id = 1040, life_span = 10,number = 1, no_fog = true,relative_pos = {x = 100, y = 0}, 
                                        --                 appear_skill = 359,--[[入场技能]]direction = "left",
                                        --                 extends_level_skills = {359},
                                        --             },
                                        --         },
                                        --     },
                                        -- },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_frame = 50},
                                                },
                                                {
                                                    CLASS = "action.QSBSummonGhosts",
                                                    OPTIONS = {
                                                        actor_id = 1041, life_span = 10,number = 1, no_fog = true,relative_pos = {x = -125, y = 0}, 
                                                        appear_skill = 365,--[[入场技能]]direction = "right",
                                                        percents = {attack = 0.8, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
                                                        extends_level_skills = {365}, same_target = true, clean_new_wave = true, is_no_deadAnimation = true
                                                    },
                                                },
                                            },
                                        },
                                        -- {
                                        --     CLASS = "composite.QSBSequence",
                                        --     ARGS = {
                                        --         {
                                        --             CLASS = "action.QSBDelayTime",
                                        --             OPTIONS = {delay_frame = 65},
                                        --         },
                                        --         {
                                        --             CLASS = "action.QSBSummonGhosts",
                                        --             OPTIONS = {
                                        --                 actor_id = 1040, life_span = 10,number = 1, no_fog = true,relative_pos = {x = 180, y = 0}, 
                                        --                 appear_skill = 360,--[[入场技能]]direction = "left",
                                        --                 extends_level_skills = {360},
                                        --             },
                                        --         },
                                        --     },
                                        -- },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_frame = 80},
                                                },
                                                {
                                                    CLASS = "action.QSBSummonGhosts",
                                                    OPTIONS = {
                                                        actor_id = 1041, life_span = 10,number = 1, no_fog = true,relative_pos = {x = 125, y = 0}, 
                                                        appear_skill = 366,--[[入场技能]]direction = "left",
                                                        percents = {attack = 0.8, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
                                                        extends_level_skills = {366}, same_target = true, clean_new_wave = true, is_no_deadAnimation = true
                                                    },
                                                },
                                            },
                                        },
                                        -- {
                                        --     CLASS = "composite.QSBSequence",
                                        --     ARGS = {
                                        --         {
                                        --             CLASS = "action.QSBDelayTime",
                                        --             OPTIONS = {delay_frame = 95},
                                        --         },
                                        --         {
                                        --             CLASS = "action.QSBSummonGhosts",
                                        --             OPTIONS = {
                                        --                 actor_id = 1040, life_span = 10,number = 1, no_fog = true,relative_pos = {x = 125, y = 0}, 
                                        --                 appear_skill = 361,--[[入场技能]]direction = "left",
                                        --                 extends_level_skills = {361},
                                        --             },
                                        --         },
                                        --     },
                                        -- },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_frame = 110},
                                                },
                                                {
                                                    CLASS = "action.QSBSummonGhosts",
                                                    OPTIONS = {
                                                        actor_id = 1041, life_span = 10,number = 1, no_fog = true,relative_pos = {x = -155, y = 0}, 
                                                        appear_skill = 367,--[[入场技能]]direction = "right",
                                                        percents = {attack = 0.8, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
                                                        extends_level_skills = {367}, same_target = true, clean_new_wave = true, is_no_deadAnimation = true
                                                    },
                                                },
                                            },
                                        },
                                    },
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            OPTIONS = {flag = 1},
                            ARGS = {
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "action.QSBPlayEffect",
                                            OPTIONS = {effect_id = "pf_zhuzhuqing01_attack11_ready", is_hit_effect = false, haste = true},
                                        },
                                        {
                                            CLASS = "action.QSBPlayEffect",
                                            OPTIONS = {effect_id = "pf_zhuzhuqing01_attack11_jump", is_hit_effect = false, haste = true},
                                        },
                                        {
                                            CLASS = "action.QSBPlayAnimation",
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_frame = 15},
                                                },
                                                {
                                                    CLASS = "composite.QSBParallel", 
                                                    ARGS = {
                                                        {
                                                            CLASS = "action.QSBHitTarget",
                                                        },
                                                        {
                                                            CLASS = "action.QSBPlayEffect",
                                                            OPTIONS = { is_hit_effect = true},
                                                        },
                                                    },
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
                                                    CLASS = "action.QSBActorFadeOut",
                                                    OPTIONS = {duration = 0.05, revertable = true},
                                                },
                                                {
                                                    CLASS = "action.QSBTeleportToTargetPos",
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
                                                    CLASS = "action.QSBActorFadeOut",
                                                    OPTIONS = {duration = 0.05, revertable = true},
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
                                                    CLASS = "action.QSBSummonGhosts",
                                                    OPTIONS = {
                                                        actor_id = 1041, life_span = 10,number = 1, no_fog = true,relative_pos = {x = -125, y = 0}, 
                                                        appear_skill = 364,--[[入场技能]]direction = "right",
                                                        percents = {attack = 0.8, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
                                                        extends_level_skills = {364}, same_target = true, clean_new_wave = true, is_no_deadAnimation = true
                                                    },
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
                                                    CLASS = "action.QSBSummonGhosts",
                                                    OPTIONS = {
                                                        actor_id = 1040, life_span = 10,number = 1, no_fog = true,relative_pos = {x = 100, y = 0}, 
                                                        appear_skill = 359,--[[入场技能]]direction = "left",
                                                        percents = {attack = 0.8, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
                                                        extends_level_skills = {359}, same_target = true, clean_new_wave = true, is_no_deadAnimation = true
                                                    },
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_frame = 70},
                                                },
                                                {
                                                    CLASS = "action.QSBSummonGhosts",
                                                    OPTIONS = {
                                                        actor_id = 1041, life_span = 10,number = 1, no_fog = true,relative_pos = {x = -125, y = 0}, 
                                                        appear_skill = 365,--[[入场技能]]direction = "right",
                                                        percents = {attack = 0.8, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
                                                        extends_level_skills = {365}, same_target = true, clean_new_wave = true, is_no_deadAnimation = true
                                                    },
                                                },
                                            },
                                        },
                                        -- {
                                        --     CLASS = "composite.QSBSequence",
                                        --     ARGS = {
                                        --         {
                                        --             CLASS = "action.QSBDelayTime",
                                        --             OPTIONS = {delay_frame = 65},
                                        --         },
                                        --         {
                                        --             CLASS = "action.QSBSummonGhosts",
                                        --             OPTIONS = {
                                        --                 actor_id = 1040, life_span = 10,number = 1, no_fog = true,relative_pos = {x = 180, y = 0}, 
                                        --                 appear_skill = 360,--[[入场技能]]direction = "left",
                                        --                 extends_level_skills = {360},
                                        --             },
                                        --         },
                                        --     },
                                        -- },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_frame = 95},
                                                },
                                                {
                                                    CLASS = "action.QSBSummonGhosts",
                                                    OPTIONS = {
                                                        actor_id = 1041, life_span = 10,number = 1, no_fog = true,relative_pos = {x = 125, y = 0}, 
                                                        appear_skill = 366,--[[入场技能]]direction = "left",
                                                        percents = {attack = 0.8, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
                                                        extends_level_skills = {366}, same_target = true, clean_new_wave = true, is_no_deadAnimation = true
                                                    },
                                                },
                                            },
                                        },
                                        -- {
                                        --     CLASS = "composite.QSBSequence",
                                        --     ARGS = {
                                        --         {
                                        --             CLASS = "action.QSBDelayTime",
                                        --             OPTIONS = {delay_frame = 95},
                                        --         },
                                        --         {
                                        --             CLASS = "action.QSBSummonGhosts",
                                        --             OPTIONS = {
                                        --                 actor_id = 1040, life_span = 10,number = 1, no_fog = true,relative_pos = {x = 125, y = 0}, 
                                        --                 appear_skill = 361,--[[入场技能]]direction = "left",
                                        --                 extends_level_skills = {361},
                                        --             },
                                        --         },
                                        --     },
                                        -- },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_frame = 110},
                                                },
                                                {
                                                    CLASS = "action.QSBSummonGhosts",
                                                    OPTIONS = {
                                                        actor_id = 1041, life_span = 10,number = 1, no_fog = true,relative_pos = {x = -150, y = 0}, 
                                                        appear_skill = 367,--[[入场技能]]direction = "right",
                                                        percents = {attack = 0.8, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
                                                        extends_level_skills = {367}, same_target = true, clean_new_wave = true, is_no_deadAnimation = true
                                                    },
                                                },
                                            },
                                        },
                                    },
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            OPTIONS = {flag = 2},
                            ARGS = {
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "action.QSBPlayEffect",
                                            OPTIONS = {effect_id = "pf_zhuzhuqing01_attack11_ready", is_hit_effect = false, haste = true},
                                        },
                                        {
                                            CLASS = "action.QSBPlayEffect",
                                            OPTIONS = {effect_id = "pf_zhuzhuqing01_attack11_jump", is_hit_effect = false, haste = true},
                                        },
                                        {
                                            CLASS = "action.QSBPlayAnimation",
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_frame = 15},
                                                },
                                                {
                                                    CLASS = "composite.QSBParallel", 
                                                    ARGS = {
                                                        {
                                                            CLASS = "action.QSBHitTarget",
                                                        },
                                                        {
                                                            CLASS = "action.QSBPlayEffect",
                                                            OPTIONS = { is_hit_effect = true},
                                                        },
                                                    },
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
                                                    CLASS = "action.QSBActorFadeOut",
                                                    OPTIONS = {duration = 0.05, revertable = true},
                                                },
                                                {
                                                    CLASS = "action.QSBTeleportToTargetPos",
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
                                                    CLASS = "action.QSBSummonGhosts",
                                                    OPTIONS = {
                                                        actor_id = 1041, life_span = 10,number = 1, no_fog = true,relative_pos = {x = -125, y = 0}, 
                                                        appear_skill = 364,--[[入场技能]]direction = "right",
                                                        percents = {attack = 0.8, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
                                                        extends_level_skills = {364}, same_target = true, clean_new_wave = true, is_no_deadAnimation = true
                                                    },
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_frame = 35},
                                                },
                                                {
                                                    CLASS = "action.QSBSummonGhosts",
                                                    OPTIONS = {
                                                        actor_id = 1040, life_span = 10,number = 1, no_fog = true,relative_pos = {x = 100, y = 0}, 
                                                        appear_skill = 359,--[[入场技能]]direction = "left",
                                                        percents = {attack = 0.8, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
                                                        extends_level_skills = {359}, same_target = true, clean_new_wave = true, is_no_deadAnimation = true
                                                    },
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
                                                    CLASS = "action.QSBSummonGhosts",
                                                    OPTIONS = {
                                                        actor_id = 1041, life_span = 10,number = 1, no_fog = true,relative_pos = {x = -125, y = 0}, 
                                                        appear_skill = 365,--[[入场技能]]direction = "right",
                                                        percents = {attack = 0.8, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
                                                        extends_level_skills = {365}, same_target = true, clean_new_wave = true, is_no_deadAnimation = true
                                                    },
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_frame = 65},
                                                },
                                                {
                                                    CLASS = "action.QSBSummonGhosts",
                                                    OPTIONS = {
                                                        actor_id = 1040, life_span = 10,number = 1, no_fog = true,relative_pos = {x = 180, y = 0}, 
                                                        appear_skill = 360,--[[入场技能]]direction = "left",
                                                        percents = {attack = 0.8, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
                                                        extends_level_skills = {360}, same_target = true, clean_new_wave = true, is_no_deadAnimation = true
                                                    },
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_frame = 90},
                                                },
                                                {
                                                    CLASS = "action.QSBSummonGhosts",
                                                    OPTIONS = {
                                                        actor_id = 1041, life_span = 10,number = 1, no_fog = true,relative_pos = {x = 125, y = 0}, 
                                                        appear_skill = 366,--[[入场技能]]direction = "left",
                                                        percents = {attack = 0.8, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
                                                        extends_level_skills = {366}, same_target = true, clean_new_wave = true, is_no_deadAnimation = true
                                                    },
                                                },
                                            },
                                        },
                                        -- {
                                        --     CLASS = "composite.QSBSequence",
                                        --     ARGS = {
                                        --         {
                                        --             CLASS = "action.QSBDelayTime",
                                        --             OPTIONS = {delay_frame = 95},
                                        --         },
                                        --         {
                                        --             CLASS = "action.QSBSummonGhosts",
                                        --             OPTIONS = {
                                        --                 actor_id = 1040, life_span = 10,number = 1, no_fog = true,relative_pos = {x = 125, y = 0}, 
                                        --                 appear_skill = 361,--[[入场技能]]direction = "left",
                                        --                 extends_level_skills = {361},
                                        --             },
                                        --         },
                                        --     },
                                        -- },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_frame = 110},
                                                },
                                                {
                                                    CLASS = "action.QSBSummonGhosts",
                                                    OPTIONS = {
                                                        actor_id = 1041, life_span = 10,number = 1, no_fog = true,relative_pos = {x = -150, y = 0}, 
                                                        appear_skill = 367,--[[入场技能]]direction = "right",
                                                        percents = {attack = 0.8, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
                                                        extends_level_skills = {367}, same_target = true, clean_new_wave = true, is_no_deadAnimation = true
                                                    },
                                                },
                                            },
                                        },
                                    },
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            OPTIONS = {flag = 3},
                            ARGS = {
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "action.QSBPlayEffect",
                                            OPTIONS = {effect_id = "pf_zhuzhuqing01_attack11_ready", is_hit_effect = false, haste = true},
                                        },
                                        {
                                            CLASS = "action.QSBPlayEffect",
                                            OPTIONS = {effect_id = "pf_zhuzhuqing01_attack11_jump", is_hit_effect = false, haste = true},
                                        },
                                        {
                                            CLASS = "action.QSBPlayAnimation",
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_frame = 15},
                                                },
                                                {
                                                    CLASS = "composite.QSBParallel", 
                                                    ARGS = {
                                                        {
                                                            CLASS = "action.QSBHitTarget",
                                                        },
                                                        {
                                                            CLASS = "action.QSBPlayEffect",
                                                            OPTIONS = { is_hit_effect = true},
                                                        },
                                                    },
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
                                                    CLASS = "action.QSBActorFadeOut",
                                                    OPTIONS = {duration = 0.05, revertable = true},
                                                },
                                                {
                                                    CLASS = "action.QSBTeleportToTargetPos",
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
                                                    CLASS = "action.QSBSummonGhosts",
                                                    OPTIONS = {
                                                        actor_id = 1041, life_span = 10,number = 1, no_fog = true,relative_pos = {x = -125, y = 0}, 
                                                        appear_skill = 364,--[[入场技能]]direction = "right",
                                                        percents = {attack = 0.8, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
                                                        extends_level_skills = {364}, same_target = true, clean_new_wave = true, is_no_deadAnimation = true
                                                    },
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_frame = 35},
                                                },
                                                {
                                                    CLASS = "action.QSBSummonGhosts",
                                                    OPTIONS = {
                                                        actor_id = 1040, life_span = 10,number = 1, no_fog = true,relative_pos = {x = 100, y = 0}, 
                                                        appear_skill = 359,--[[入场技能]]direction = "left",
                                                        percents = {attack = 0.8, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
                                                        extends_level_skills = {359}, same_target = true, clean_new_wave = true, is_no_deadAnimation = true
                                                    },
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
                                                    CLASS = "action.QSBSummonGhosts",
                                                    OPTIONS = {
                                                        actor_id = 1041, life_span = 10,number = 1, no_fog = true,relative_pos = {x = -125, y = 0}, 
                                                        appear_skill = 365,--[[入场技能]]direction = "right",
                                                        percents = {attack = 0.8, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
                                                        extends_level_skills = {365}, same_target = true, clean_new_wave = true, is_no_deadAnimation = true
                                                    },
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_frame = 65},
                                                },
                                                {
                                                    CLASS = "action.QSBSummonGhosts",
                                                    OPTIONS = {
                                                        actor_id = 1040, life_span = 10,number = 1, no_fog = true,relative_pos = {x = 180, y = 0}, 
                                                        appear_skill = 360,--[[入场技能]]direction = "left",
                                                        percents = {attack = 0.8, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
                                                        extends_level_skills = {360}, same_target = true, clean_new_wave = true, is_no_deadAnimation = true
                                                    },
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_frame = 80},
                                                },
                                                {
                                                    CLASS = "action.QSBSummonGhosts",
                                                    OPTIONS = {
                                                        actor_id = 1041, life_span = 10,number = 1, no_fog = true,relative_pos = {x = -125, y = 0}, 
                                                        appear_skill = 366,--[[入场技能]]direction = "right",
                                                        percents = {attack = 0.8, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
                                                        extends_level_skills = {366}, same_target = true, clean_new_wave = true, is_no_deadAnimation = true
                                                    },
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_frame = 95},
                                                },
                                                {
                                                    CLASS = "action.QSBSummonGhosts",
                                                    OPTIONS = {
                                                        actor_id = 1040, life_span = 10,number = 1, no_fog = true,relative_pos = {x = 125, y = 0}, 
                                                        appear_skill = 361,--[[入场技能]]direction = "left",
                                                        percents = {attack = 0.8, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
                                                        extends_level_skills = {361}, same_target = true, clean_new_wave = true, is_no_deadAnimation = true
                                                    },
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_frame = 110},
                                                },
                                                {
                                                    CLASS = "action.QSBSummonGhosts",
                                                    OPTIONS = {
                                                        actor_id = 1041, life_span = 10,number = 1, no_fog = true,relative_pos = {x = -150, y = 0}, 
                                                        appear_skill = 367,--[[入场技能]]direction = "right",
                                                        percents = {attack = 0.8, physical_damage_percent_attack = 1, magic_damage_percent_attack = 1}, --[[属性基于召唤者属性的百分比系数]]
                                                        extends_level_skills = {367}, same_target = true, clean_new_wave = true, is_no_deadAnimation = true
                                                    },
                                                },
                                            },
                                        },
                                    },
                                },
                            },
                        },
                    },
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 32},
                },
                {
                    CLASS = "action.QSBActorFadeIn",
                    OPTIONS = {duration = 0.05, revertable = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "mianyi_suoyou_shanghai", is_target = false},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return zhuzhuqing_dazhao