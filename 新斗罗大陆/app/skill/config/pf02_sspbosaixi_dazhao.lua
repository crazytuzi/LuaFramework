local common_xiaoqiang_victory = 
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
                    OPTIONS = {delay_time = 3.5},
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
                    OPTIONS = {delay_time = 3.5},
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
            OPTIONS = {is_target = false, buff_id = "ssayin_mianyi"},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 3 },
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
                    OPTIONS = {delay_time = 0.5 },
                },
                {
                    CLASS = "action.QSBPlaySound",
                    OPTIONS = {sound_id ="sspbosaixi_skill"},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {          
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 2},
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
                                    OPTIONS = {delay_frame = 5},
                                },                      
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "pf02_sspbosaixi_attack11_1", is_hit_effect = false},
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "pf02_sspbosaixi_attack11_2", is_hit_effect = false},
                        },   
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "pf02_sspbosaixi_attack11_3", is_hit_effect = false},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "pf02_sspbosaixi_attack11_4", is_hit_effect = false},
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
                    OPTIONS = {delay_frame = 2},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                },                        
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 60},
                },
                {
                    CLASS = "action.QSBArgsConditionSelector",
                    OPTIONS = {
                        failed_select = -1,
                        {expression = "self:has_buff:sspbosaixi_sj5", select = 1},
                    }
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = 
                    {
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = {           
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {buff_id = "sspbosaixi_sj5_debuff1", enemy = true},
                                }, 
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {buff_id = "pf02_sspbosaixi_sj5_debuff2", enemy = true},
                                }, 
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {buff_id = "pf02_sspbosaixi_sj5_debuff3", enemy = true},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {buff_id = "sspbosaixi_sj_jiance", enemy = true},
                                },
                            },
                        },
                    },
                },
                {
                    CLASS = "action.QSBArgsConditionSelector",
                    OPTIONS = 
                    {
                        failed_select = 2,
                        {expression = "self:is_pvp=true", select = 1},
                    },
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
                                    CLASS = "action.QSBArgsConditionSelector",
                                    OPTIONS = 
                                    {
                                        failed_select = 4,
                                        {expression = "target:buff_num:sspbosaixi_sj3_debuff1>0", select = 1},
                                        {expression = "target:buff_num:sspbosaixi_sj4_debuff1>0", select = 2},
                                        {expression = "target:buff_num:sspbosaixi_sj5_debuff1>0", select = 3},
                                    },
                                },
                                {
                                    CLASS = "composite.QSBSelector",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBDecreaseHpByTargetProp", --造成攻击目标当前生命20%伤害
                                            OPTIONS = {is_max_hp_percent = true, current_hp_percent = true, hp_percent = 0.25},
                                        },
                                        {
                                            CLASS = "action.QSBDecreaseHpByTargetProp", --造成攻击目标当前生命20%伤害
                                            OPTIONS = {is_max_hp_percent = true, current_hp_percent = true, hp_percent = 0.3},
                                        },
                                        {
                                            CLASS = "action.QSBDecreaseHpByTargetProp", --造成攻击目标当前生命20%伤害
                                            OPTIONS = {is_max_hp_percent = true, current_hp_percent = true, hp_percent = 0.35},
                                        },
                                        {
                                            CLASS = "action.QSBDecreaseHpByTargetProp", --造成攻击目标当前生命20%伤害
                                            OPTIONS = {is_max_hp_percent = true, current_hp_percent = true, hp_percent = 0},
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
                                    CLASS = "action.QSBArgsConditionSelector",
                                    OPTIONS = 
                                    {
                                        failed_select = 4,
                                        {expression = "target:buff_num:sspbosaixi_sj3_debuff1>0", select = 1},
                                        {expression = "target:buff_num:sspbosaixi_sj4_debuff1>0", select = 2},
                                        {expression = "target:buff_num:sspbosaixi_sj5_debuff1>0", select = 3},
                                    },
                                },
                                {
                                    CLASS = "composite.QSBSelector",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBHitTarget",
                                            OPTIONS = {damage_scale = 0.2,check_target_by_skill = true},
                                        },
                                        {
                                            CLASS = "action.QSBHitTarget",
                                            OPTIONS = {damage_scale = 0.45,check_target_by_skill = true},
                                        },
                                        {
                                            CLASS = "action.QSBHitTarget",
                                            OPTIONS = {damage_scale = 0.7,check_target_by_skill = true},
                                        },
                                        {
                                            CLASS = "action.QSBHitTarget",
                                            OPTIONS = {damage_scale = 0,check_target_by_skill = true},
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
                    OPTIONS = {delay_frame = 60},
                },
                {
                  CLASS = "action.QSBHitTarget",
                },                       
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 60},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {   
                        {
                          CLASS = "action.QSBPlaySceneEffect",
                          OPTIONS = {effect_id = "pf02_sspbosaixi_attack11_6", pos  = {x = 375 , y = 175}, ground_layer = true},
                        },
                        {
                          CLASS = "action.QSBPlaySceneEffect",
                          OPTIONS = {effect_id = "pf02_sspbosaixi_attack11_5", pos  = {x = 875 , y = 175}, ground_layer = true},
                        },                        
                        {
                          CLASS = "action.QSBPlaySceneEffect",
                          OPTIONS = {effect_id = "pf02_sspbosaixi_attack11_8", pos  = {x = 500 , y = 325}, ground_layer = true},
                        },
                        {
                          CLASS = "action.QSBPlaySceneEffect",
                          OPTIONS = {effect_id = "pf02_sspbosaixi_attack11_7", pos  = {x = 800 , y = 325}, ground_layer = true},
                        },
                        {
                          CLASS = "action.QSBPlaySceneEffect",
                          OPTIONS = {effect_id = "pf02_sspbosaixi_attack11_8", pos  = {x = 200 , y = 325}, ground_layer = true},
                        },
                        {
                          CLASS = "action.QSBPlaySceneEffect",
                          OPTIONS = {effect_id = "pf02_sspbosaixi_attack11_7", pos  = {x = 1100 , y = 325}, ground_layer = true},
                        },
                        {
                          CLASS = "action.QSBPlaySceneEffect",
                          OPTIONS = {effect_id = "pf02_sspbosaixi_attack11_10", pos  = {x = 375 , y = 475}, ground_layer = true},
                        },
                        {
                          CLASS = "action.QSBPlaySceneEffect",
                          OPTIONS = {effect_id = "pf02_sspbosaixi_attack11_9", pos  = {x = 875 , y = 475}, ground_layer = true},
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
                    OPTIONS = {delay_frame = 68},
                },
                {
                    CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 4, duration = 0.35, count = 2,},
                },
            },
        },                           
    },
}

return common_xiaoqiang_victory