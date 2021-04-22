local common_xiaoqiang_victory = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBShowActor",
                            OPTIONS = {is_attacker = true, turn_on = true, time = 0.6},
                        },
                        {
                            CLASS = "action.QSBBulletTime",
                            OPTIONS = {turn_on = true, revertable = false},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 4.25},
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
                            OPTIONS = {delay_time = 4.25},
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
                    OPTIONS = {is_target = false, buff_id = "sszhuzhuqing_mianyi"},
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.1},
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBActorFadeOut",
                                            OPTIONS = {duration = 0.15, revertable = true},
                                        },                                     
                                    },
                                },
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBDelayTime",
                                            OPTIONS = {delay_time = 0.175},
                                        },
                                        {
                                            CLASS = "composite.QSBParallel",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "composite.QSBSequence",
                                                    ARGS = 
                                                    {
                                                        {
                                                            CLASS = "action.QSBDelayTime",
                                                            OPTIONS = {delay_time = 0.2},
                                                        },
                                                        {
                                                            CLASS = "action.QSBTeleportToTargetBehind",
                                                            OPTIONS = {verify_flip = true},
                                                        },
                                                    },
                                                },
                                                {
                                                    CLASS = "composite.QSBSequence",
                                                    ARGS = 
                                                    {
                                                        {
                                                            CLASS = "action.QSBDelayTime",
                                                            OPTIONS = {delay_time = 0.35},
                                                        },
                                                        {
                                                            CLASS = "action.QSBPlayEffect",
                                                            OPTIONS = {effect_id = "pf_sszhuzhuqing_dazhao_ruchang1" ,is_hit_effect = false},
                                                        },
                                                    },
                                                },
                                                {
                                                    CLASS = "composite.QSBSequence",
                                                    OPTIONS = {forward_mode = true},
                                                    ARGS = 
                                                    {
                                                        {
                                                            CLASS = "action.QSBDelayTime",
                                                            OPTIONS = {delay_time = 1.4},
                                                        },
                                                        {
                                                            CLASS = "action.QSBArgsIsDirectionLeft",
                                                            OPTIONS = {is_attacker = true},
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
                                                                            CLASS = "action.QSBSSZhuzhuQingRangeOffset",
                                                                            OPTIONS = {speed = -800,duration = 0.5},
                                                                        },
                                                                        {
                                                                            CLASS = "action.QSBDelayTime",
                                                                            OPTIONS = {delay_time = 1},
                                                                        },
                                                                        {
                                                                            CLASS = "action.QSBSSZhuzhuQingRangeOffset",
                                                                            OPTIONS = {speed = 1600,duration = 0.25,offset =  {x = -400, y = 0}},
                                                                        },
                                                                    },
                                                                },
                                                                {
                                                                    CLASS = "composite.QSBSequence",
                                                                    ARGS = 
                                                                    {
                                                                        {
                                                                            CLASS = "action.QSBSSZhuzhuQingRangeOffset",
                                                                            OPTIONS = {speed = 800,duration = 0.5},
                                                                        },
                                                                        {
                                                                            CLASS = "action.QSBDelayTime",
                                                                            OPTIONS = {delay_time = 1},
                                                                        },
                                                                        {
                                                                            CLASS = "action.QSBSSZhuzhuQingRangeOffset",
                                                                            OPTIONS = {speed = -1600,duration = 0.25,offset =  {x = 400, y = 0}},
                                                                        },
                                                                    },
                                                                },
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
                                                            OPTIONS = {delay_time = 0.225},
                                                        },
                                                        {
                                                            CLASS = "composite.QSBParallel",
                                                            ARGS = 
                                                            {
                                                                {
                                                                    CLASS = "action.QSBActorFadeIn",
                                                                    OPTIONS = {duration = 0.8, revertable = true},
                                                                },
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "pf_sszzq_sj_cf5" ,is_hit_effect = false},
                                                                },                                                     
                                                                {
                                                                    CLASS = "composite.QSBSequence",
                                                                    ARGS = 
                                                                    {
                                                                        {
                                                                            CLASS = "action.QSBDelayTime",
                                                                            OPTIONS = {delay_time = 0.65},
                                                                        },  
                                                                        {
                                                                            CLASS = "action.QSBShakeScreen",
                                                                            OPTIONS = {amplitude = 3, duration = 0.35, count = 2,},
                                                                        }, 
                                                                    },
                                                                },    
                                                                {
                                                                    CLASS = "action.QSBPlayAnimation",
                                                                    OPTIONS = {animation = "attack11_1"},
                                                                },
                                                                {   
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {effect_id = "pf_sszzq_dz_1_l"},
                                                                },                                                                                                                                
                                                                {
                                                                    CLASS = "composite.QSBSequence",
                                                                    ARGS = 
                                                                    {
                                                                        {
                                                                            CLASS = "action.QSBDelayTime",
                                                                            OPTIONS = {delay_time = 0.5},
                                                                        },  
                                                                        {
                                                                            CLASS = "action.QSBDelayTime",
                                                                            OPTIONS = {delay_time = 0.5},
                                                                        },                                                              
                                                                        {
                                                                            CLASS = "composite.QSBParallel",
                                                                            ARGS = 
                                                                            {                                                                                
                                                                                {
                                                                                    CLASS = "action.QSBPlayAnimation",
                                                                                    OPTIONS = {animation = "attack11_2"},
                                                                                },
                                                                                {
                                                                                    CLASS = "composite.QSBSequence",
                                                                                    ARGS = 
                                                                                    {
                                                                                        {
                                                                                            CLASS = "action.QSBDelayTime",
                                                                                            OPTIONS = {delay_time = 0.3},
                                                                                        },  
                                                                                        {   
                                                                                            CLASS = "action.QSBPlayEffect",
                                                                                            OPTIONS = {effect_id = "pf_sszzq_dz_1_r"},
                                                                                        },
                                                                                    },
                                                                                },
                                                                                {
                                                                                    CLASS = "composite.QSBSequence",
                                                                                    ARGS = 
                                                                                    {
                                                                                        {
                                                                                            CLASS = "action.QSBDelayTime",
                                                                                            OPTIONS = {delay_time = 1.6},
                                                                                        },  
                                                                                        {   
                                                                                            CLASS = "action.QSBPlayEffect",
                                                                                            OPTIONS = {effect_id = "pf_sszzq_attack11_2_3"},
                                                                                        },
                                                                                    },
                                                                                },
                                                                                {
                                                                                    CLASS = "composite.QSBSequence",
                                                                                    ARGS = 
                                                                                    {
                                                                                        {
                                                                                            CLASS = "action.QSBDelayTime",
                                                                                            OPTIONS = {delay_time = 2},
                                                                                        },
                                                                                        {
                                                                                            CLASS = "composite.QSBSequence",
                                                                                            OPTIONS = {forward_mode = true},
                                                                                            ARGS = 
                                                                                            {
                                                                                                {
                                                                                                    CLASS = "action.QSBArgsIsDirectionLeft",
                                                                                                    OPTIONS = {is_attacker = true},
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
                                                                                                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                                                                                                    OPTIONS = {interval_time = 0.01, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "pf_sszhuzhuqing_dazhao_2"},
                                                                                                                },
                                                                                                            },
                                                                                                        },
                                                                                                        {
                                                                                                            CLASS = "composite.QSBSequence",
                                                                                                            ARGS = 
                                                                                                            {
                                                                                                                {
                                                                                                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                                                                                                    OPTIONS = {interval_time = 0.01, attacker_face = false,attacker_underfoot = true,count = 1, distance = 150, trapId = "pf_sszhuzhuqing_dazhao_1"},
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
                                                                        },
                                                                    },
                                                                },
                                                                {
                                                                    CLASS = "composite.QSBSequence",
                                                                    ARGS = 
                                                                    {
                                                                        {
                                                                            CLASS = "action.QSBDelayTime",
                                                                            OPTIONS = {delay_time = 0.5},
                                                                        },
                                                                        {
                                                                            CLASS = "action.QSBApplyBuff",
                                                                            OPTIONS = {is_target = true, buff_id = "jingu_3s"},
                                                                        },
                                                                        {
                                                                            CLASS = "action.QSBApplyBuff",
                                                                            OPTIONS = {is_target = true, buff_id = "dazhao_fumo_debuff1_1"},
                                                                        },                                                                                                                                               
                                                                    },
                                                                },
                                                            },
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
                                                            OPTIONS = {delay_time = 1.75 },
                                                        },
                                                        {
                                                            CLASS = "action.QSBPlaySound",
                                                            OPTIONS = {sound_id ="pf_sszhuzhuqing01_skill"},
                                                        },
                                                    },
                                                },
                                                {
                                                    CLASS = "composite.QSBSequence",
                                                    ARGS = 
                                                    {
                                                        {
                                                            CLASS = "action.QSBDelayTime",
                                                            OPTIONS = {delay_time = 1.75},
                                                        },                                                        
                                                        {
                                                            CLASS = "composite.QSBParallel",
                                                            ARGS = 
                                                            { 
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {is_hit_effect = true, effect_id = "pf_sszzq_dz_2"},
                                                                }, 
                                                                {
                                                                    CLASS = "composite.QSBSequence",
                                                                    ARGS = 
                                                                    {
                                                                        {
                                                                            CLASS = "action.QSBArgsConditionSelector",
                                                                            OPTIONS = 
                                                                            {
                                                                                failed_select = 1,
                                                                                {expression = "target:buff_num:pf_sszhuzhuqing_sj1_youmming=0", select = 1},
                                                                                {expression = "target:buff_num:pf_sszhuzhuqing_sj1_youmming=1", select = 2},
                                                                                {expression = "target:buff_num:pf_sszhuzhuqing_sj1_youmming=2", select = 3},
                                                                                {expression = "target:buff_num:pf_sszhuzhuqing_sj1_youmming=3", select = 4},
                                                                                {expression = "target:buff_num:pf_sszhuzhuqing_sj1_youmming=4", select = 5},
                                                                                {expression = "target:buff_num:pf_sszhuzhuqing_sj1_youmming=5", select = 6},
                                                                            }
                                                                        },
                                                                        {
                                                                            CLASS = "composite.QSBSelector",
                                                                            ARGS = 
                                                                            {
                                                                                {
                                                                                    CLASS = "action.QSBHitTarget",                                                                                    
                                                                                },
                                                                                {
                                                                                    CLASS = "action.QSBHitTarget",
                                                                                    OPTIONS = {property_promotion = {critical_damage = 0.4 }},
                                                                                },
                                                                                {
                                                                                    CLASS = "action.QSBHitTarget",
                                                                                    OPTIONS = {property_promotion = { critical_damage = 0.6 }},
                                                                                },
                                                                                {
                                                                                    CLASS = "action.QSBHitTarget",
                                                                                    OPTIONS = {property_promotion = { critical_damage = 0.8 }},
                                                                                },
                                                                                {
                                                                                    CLASS = "action.QSBHitTarget",
                                                                                    OPTIONS = {property_promotion = { critical_damage = 1 }},
                                                                                },
                                                                                {
                                                                                    CLASS = "action.QSBHitTarget",
                                                                                    OPTIONS = {property_promotion = {critical_damage = 1.2 }},
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
                                                    CLASS = "composite.QSBSequence",
                                                    ARGS = 
                                                    {
                                                        {
                                                            CLASS = "action.QSBDelayTime",
                                                            OPTIONS = {delay_time = 2},
                                                        },                                                        
                                                        {
                                                            CLASS = "composite.QSBParallel",
                                                            ARGS = 
                                                            { 
                                                                {
                                                                    CLASS = "action.QSBPlayEffect",
                                                                    OPTIONS = {is_hit_effect = true, effect_id = "pf_sszzq_dz_2"},
                                                                }, 
                                                                {
                                                                    CLASS = "composite.QSBSequence",
                                                                    ARGS = 
                                                                    {
                                                                        {
                                                                            CLASS = "action.QSBArgsConditionSelector",
                                                                            OPTIONS = 
                                                                            {
                                                                                failed_select = 1,
                                                                                {expression = "target:buff_num:pf_sszhuzhuqing_sj1_youmming=0", select = 1},
                                                                                {expression = "target:buff_num:pf_sszhuzhuqing_sj1_youmming=1", select = 2},
                                                                                {expression = "target:buff_num:pf_sszhuzhuqing_sj1_youmming=2", select = 3},
                                                                                {expression = "target:buff_num:pf_sszhuzhuqing_sj1_youmming=3", select = 4},
                                                                                {expression = "target:buff_num:pf_sszhuzhuqing_sj1_youmming=4", select = 5},
                                                                                {expression = "target:buff_num:pf_sszhuzhuqing_sj1_youmming=5", select = 6},
                                                                            }
                                                                        },
                                                                        {
                                                                            CLASS = "composite.QSBSelector",
                                                                            ARGS = 
                                                                            {
                                                                                {
                                                                                    CLASS = "action.QSBHitTarget",                                                                                    
                                                                                },
                                                                                {
                                                                                    CLASS = "action.QSBHitTarget",
                                                                                    OPTIONS = {property_promotion = {critical_damage = 0.4 }},
                                                                                },
                                                                                {
                                                                                    CLASS = "action.QSBHitTarget",
                                                                                    OPTIONS = {property_promotion = { critical_damage = 0.6 }},
                                                                                },
                                                                                {
                                                                                    CLASS = "action.QSBHitTarget",
                                                                                    OPTIONS = {property_promotion = { critical_damage = 0.8 }},
                                                                                },
                                                                                {
                                                                                    CLASS = "action.QSBHitTarget",
                                                                                    OPTIONS = {property_promotion = { critical_damage = 1 }},
                                                                                },
                                                                                {
                                                                                    CLASS = "action.QSBHitTarget",
                                                                                    OPTIONS = {property_promotion = {critical_damage = 1.2 }},
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
                                                    CLASS = "composite.QSBSequence",
                                                    ARGS = 
                                                    {
                                                        {
                                                            CLASS = "action.QSBDelayTime",
                                                            OPTIONS = {delay_time = 2.25},
                                                        }, 
                                                        {
                                                            CLASS = "composite.QSBParallel",
                                                            ARGS = 
                                                            { 
                                                                {
                                                                    CLASS = "action.QSBRemoveBuff",
                                                                    OPTIONS = {is_target = true, buff_id = "anqi_zhugeshennupao_fangyu_die1"},
                                                                },
                                                                {
                                                                    CLASS = "action.QSBRemoveBuff",
                                                                    OPTIONS = {is_target = true, buff_id = "anqi_zhugeshennupao_fangyu_die2"},
                                                                },
                                                                {
                                                                    CLASS = "action.QSBRemoveBuff",
                                                                    OPTIONS = {is_target = true, buff_id = "anqi_zhugeshennupao_fangyu_die3"},
                                                                },
                                                                {
                                                                    CLASS = "action.QSBRemoveBuff",
                                                                    OPTIONS = {is_target = true, buff_id = "anqi_zhugeshennupao_fangyu_die4"},
                                                                },
                                                                {
                                                                    CLASS = "action.QSBRemoveBuff",
                                                                    OPTIONS = {is_target = true, buff_id = "anqi_zhugeshennupao_fangyu_die5"},
                                                                },
                                                            },
                                                        },                                                       
                                                        {
                                                            CLASS = "composite.QSBSequence",
                                                            ARGS = 
                                                            {
                                                                {
                                                                    CLASS = "composite.QSBParallel",
                                                                    ARGS = 
                                                                    { 
                                                                        {
                                                                            CLASS = "action.QSBPlayEffect",
                                                                            OPTIONS = {is_hit_effect = true, effect_id = "pf_sszzq_dz_2"},
                                                                        }, 
                                                                        {
                                                                            CLASS = "composite.QSBSequence",
                                                                            ARGS = 
                                                                            {
                                                                                {
                                                                                    CLASS = "action.QSBArgsConditionSelector",
                                                                                    OPTIONS = 
                                                                                    {
                                                                                        failed_select = 1,
                                                                                        {expression = "target:buff_num:pf_sszhuzhuqing_sj1_youmming=0", select = 1},
                                                                                        {expression = "target:buff_num:pf_sszhuzhuqing_sj1_youmming=1", select = 2},
                                                                                        {expression = "target:buff_num:pf_sszhuzhuqing_sj1_youmming=2", select = 3},
                                                                                        {expression = "target:buff_num:pf_sszhuzhuqing_sj1_youmming=3", select = 4},
                                                                                        {expression = "target:buff_num:pf_sszhuzhuqing_sj1_youmming=4", select = 5},
                                                                                        {expression = "target:buff_num:pf_sszhuzhuqing_sj1_youmming=5", select = 6},
                                                                                    },
                                                                                },
                                                                            	{
                                                                                    CLASS = "composite.QSBSelector",
                                                                                    ARGS = 
                                                                                    {
                                                                                        {
                                                                                            CLASS = "action.QSBHitTarget",                                                                                    
                                                                                        },
                                                                                        {
                                                                                            CLASS = "action.QSBHitTarget",
                                                                                            OPTIONS = {property_promotion = {critical_damage = 0.4 }},
                                                                                        },
                                                                                        {
                                                                                            CLASS = "action.QSBHitTarget",
                                                                                            OPTIONS = {property_promotion = { critical_damage = 0.6 }},
                                                                                        },
                                                                                        {
                                                                                            CLASS = "action.QSBHitTarget",
                                                                                            OPTIONS = {property_promotion = { critical_damage = 0.8 }},
                                                                                        },
                                                                                        {
                                                                                            CLASS = "action.QSBHitTarget",
                                                                                            OPTIONS = {property_promotion = { critical_damage = 1 }},
                                                                                        },
                                                                                        {
                                                                                            CLASS = "action.QSBHitTarget",
                                                                                            OPTIONS = {property_promotion = {critical_damage = 1.2 }},
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
                                                },
                                                {
                                                    CLASS = "composite.QSBSequence",
                                                    ARGS = 
                                                    {
                                                        {
                                                            CLASS = "action.QSBDelayTime",
                                                            OPTIONS = {delay_time = 3.6},
                                                        },                                                       
                                                        {
                                                            CLASS = "composite.QSBParallel",
                                                            ARGS = 
                                                            { 
                                                                {
                                                                    CLASS = "composite.QSBSequence",
                                                                    OPTIONS = {forward_mode = true},
                                                                    ARGS = 
                                                                    {
                                                                        {
                                                                            CLASS = "action.QSBArgsIsDirectionLeft",
                                                                            OPTIONS = {is_attacker = true},
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
                                                                                            CLASS = "action.QSBPlayEffect",
                                                                                            OPTIONS = {effect_id = "pf_sszzq_dz_3_r" ,is_hit_effect = false},
                                                                                        },
                                                                                    },
                                                                                },
                                                                                {
                                                                                    CLASS = "composite.QSBSequence",
                                                                                    ARGS = 
                                                                                    {
                                                                                        {
                                                                                            CLASS = "action.QSBPlayEffect",
                                                                                            OPTIONS = {effect_id = "pf_sszzq_dz_3_l" ,is_hit_effect = false },
                                                                                        },
                                                                                    },
                                                                                },
                                                                            },
                                                                        },
                                                                    },
                                                                },
                                                                {
                                                                    CLASS = "action.QSBShakeScreen",
                                                                    OPTIONS = {amplitude = 4, duration = 0.35, count = 2,},
                                                                },                                                                                                                            
                                                                {
                                                                    CLASS = "composite.QSBSequence",
                                                                    ARGS = 
                                                                    {
                                                                        {
                                                                            CLASS = "action.QSBArgsConditionSelector",
                                                                            OPTIONS = 
                                                                            {
                                                                                failed_select = 1,
                                                                                {expression = "target:buff_num:pf_sszhuzhuqing_sj1_youmming=0", select = 1},
                                                                                {expression = "target:buff_num:pf_sszhuzhuqing_sj1_youmming=1", select = 2},
                                                                                {expression = "target:buff_num:pf_sszhuzhuqing_sj1_youmming=2", select = 3},
                                                                                {expression = "target:buff_num:pf_sszhuzhuqing_sj1_youmming=3", select = 4},
                                                                                {expression = "target:buff_num:pf_sszhuzhuqing_sj1_youmming=4", select = 5},
                                                                                {expression = "target:buff_num:pf_sszhuzhuqing_sj1_youmming=5", select = 6},
                                                                            }
                                                                        },
                                                                        {
                                                                            CLASS = "composite.QSBSelector",
                                                                            ARGS = 
                                                                            {
                                                                                {
                                                                                    CLASS = "action.QSBHitTarget",                                                                                    
                                                                                },
                                                                                {
                                                                                    CLASS = "action.QSBHitTarget",
                                                                                    OPTIONS = {property_promotion = { critical_chance = 0.1,critical_damage = 0.4 }},
                                                                                },
                                                                                {
                                                                                    CLASS = "action.QSBHitTarget",
                                                                                    OPTIONS = {property_promotion = { critical_chance = 0.2,critical_damage = 0.6 }},
                                                                                },
                                                                                {
                                                                                    CLASS = "action.QSBHitTarget",
                                                                                    OPTIONS = {property_promotion = { critical_chance = 0.3,critical_damage = 0.8 }},
                                                                                },
                                                                                {
                                                                                    CLASS = "action.QSBHitTarget",
                                                                                    OPTIONS = {property_promotion = { critical_chance = 0.4,critical_damage = 1 }},
                                                                                },
                                                                                {
                                                                                    CLASS = "action.QSBHitTarget",
                                                                                    OPTIONS = {property_promotion = { critical_chance = 0.5,critical_damage = 1.2 }},
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
}

return common_xiaoqiang_victory