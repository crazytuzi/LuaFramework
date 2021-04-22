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
                    OPTIONS = {delay_time = 2.5},
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
                    OPTIONS = {delay_time = 2.5},
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
                    OPTIONS = {delay_frame = 45 },
                },
                 {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = {"pf3_sspqianrenxue_dazhao_treat"}, is_target = false},--回血Buff
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 0.5 },
                },
                {
                    CLASS = "action.QSBPlaySound",
                    OPTIONS = {sound_id ="pf_sspqianrenxue03_skill"},--声音
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {          
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 14},
                },                                          
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf3_sspqianrenxue_attack11_1", is_hit_effect = false},--飞升特效
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {          
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 96},
                },                                          
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf3_sspqianrenxue_attack11_3", is_hit_effect = false},--下降特效
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 30 },
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
                                        OPTIONS = {forward_mode = true},
                                        ARGS = {
                                            {
                                                CLASS = "action.QSBArgsPosition",
                                                OPTIONS = {is_attackee = true},
                                            },
                                            {
                                                CLASS = "action.QSBPlaySceneEffect",
                                                OPTIONS = {effect_id = "pf3_sspqianrenxue_attack11_7_r", ground_layer = true},--预警特效
                                            },
                                        },
                                    },
                                    {
                                        CLASS = "composite.QSBSequence",
                                        OPTIONS = {forward_mode = true},
                                        ARGS = {
                                            {
                                                CLASS = "action.QSBArgsPosition",
                                                OPTIONS = {is_attackee = true},
                                            },        
                                            {
                                                CLASS = "action.QSBPlaySceneEffect",
                                                OPTIONS = {effect_id = "pf3_sspqianrenxue_attack11_7", ground_layer = true},--右半场预警特效
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
                    OPTIONS = {delay_frame = 57 },
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
                                        OPTIONS = {forward_mode = true},
                                        ARGS = {
                                            {
                                                CLASS = "action.QSBArgsPosition",
                                                OPTIONS = {is_attackee = true},
                                            },
                                            {
                                                CLASS = "action.QSBPlaySceneEffect",
                                                OPTIONS = {effect_id = "pf3_sspqianrenxue_attack11_2_r", front_layer = true},--龙特效
                                            },
                                        },
                                    },
                                    {
                                        CLASS = "composite.QSBSequence",
                                        OPTIONS = {forward_mode = true},
                                        ARGS = {
                                            {
                                                CLASS = "action.QSBArgsPosition",
                                                OPTIONS = {is_attackee = true},
                                            },        
                                            {
                                                CLASS = "action.QSBPlaySceneEffect",
                                                OPTIONS = {effect_id = "pf3_sspqianrenxue_attack11_2", front_layer = true},--右半场龙特效
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
                    OPTIONS = {delay_frame = 62},
                },                                          
                {
                    CLASS = "composite.QSBSequence",
                    OPTIONS = {forward_mode = true},
                    ARGS = {
                        {
                            CLASS = "action.QSBArgsPosition",
                            OPTIONS = {is_attackee = true},
                        },        
                        {
                            CLASS = "action.QSBPlaySceneEffect",
                            OPTIONS = {effect_id = "pf3_sspqianrenxue_attack11_4", front_layer = true},--前层特效
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
                    OPTIONS = {delay_frame = 62},
                },                                          
                {
                    CLASS = "composite.QSBSequence",
                    OPTIONS = {forward_mode = true},
                    ARGS = {
                        {
                            CLASS = "action.QSBArgsPosition",
                            OPTIONS = {is_attackee = true},
                        },        
                        {
                            CLASS = "action.QSBPlaySceneEffect",
                            OPTIONS = {effect_id = "pf3_sspqianrenxue_attack11_5", front_layer = true},--后层特效
                        },
                    },
                },
            },
        },
        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = 
        --     {          
        --         {
        --             CLASS = "action.QSBDelayTime",
        --             OPTIONS = {delay_frame = 12},
        --         },                                          
        --         {
        --             CLASS = "action.QSBPlayEffect",
        --             OPTIONS = {effect_id = "pf3_sspqianrenxue_attack11_6", is_hit_effect = false},--下层法阵特效
        --         },
        --     },
        -- },
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
                    OPTIONS = {animation = "attack11_1" , no_stand = true },
                },                       
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 96 },
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack11_2" , no_stand = true },
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
                    OPTIONS = {delay_frame = 51 },
                },
                {
                    CLASS = "action.QSBActorFadeOut",
                    OPTIONS = {duration = 0.01, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 45 },
                },
                {
                    CLASS = "action.QSBActorFadeIn",
                    OPTIONS = {duration = 0.01, revertable = true},
                }, 
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 70},
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
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
                                    CLASS = "composite.QSBParallel",
                                    ARGS = 
                                    { 
                                        {
                                          CLASS = "action.QSBHitTarget",
                                          OPTIONS = {damage_scale = 1.25,check_target_by_skill = true},
                                        }, 
                                    },
                                },
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = 
                                    { 
                                        {
                                          CLASS = "action.QSBHitTarget",
                                          OPTIONS = {damage_scale = 1.35,check_target_by_skill = true},
                                        }, 
                                    },
                                },
                            },
                        },
                    },
                }, 
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "pf3_sspqianrenxue_dazhao_treat", is_target = false},--回血Buff移除
                },                        
            },
        },  
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 62},
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