-- 技能 唐昊大招
-- 技能ID 604
-- 打三下,每次伤害后若目标处于位面失衡状态且血量少于60%，则将其斩杀
-- 神3后,击杀目标后切换下个敌人继续打.
-- 攻击走神技判定
--[[
    魂师 昊天唐昊
    ID:1058
    psf 2020-7-28
]]--

local function HIT_WITH_SHENJI(df,ds) 
    local hit_node
    hit_node ={
        CLASS = "composite.QSBSequence",
        ARGS = 
        {
            {
                CLASS = "action.QSBDelayTime",OPTIONS = {delay_frame = df},
            },  
            --真技7效果:
            {
                CLASS = "action.QSBArgsConditionSelector",
                OPTIONS = {
                    failed_select = 3,
                    {expression = "self:ssptanghao_zj7&target:has_buff:ssptanghao_zhenji7_debuff", select = 1},
                    {expression = "self:ssptanghao_zj7", select = 1},
                }
            },
            {
                CLASS = "composite.QSBSelector",
                ARGS = {    
                    {
                        CLASS = "action.QSBApplyBuff",OPTIONS = {buff_id = "ssptanghao_zhenji7_debuff", is_target = true},
                    }, 
                    {
                        CLASS = "composite.QSBSequence",
                        ARGS = {
                            {
                                CLASS = "action.QSBRemoveBuff",OPTIONS = {buff_id = "ssptanghao_zhenji7_debuff", remove_all_same_buff_id = true, enemy = true},
                            },
                            {
                                CLASS = "action.QSBApplyBuff",OPTIONS = {buff_id = "ssptanghao_zhenji7_debuff", is_target = true},
                            }, 
                        },
                    }, 
                },
            }, 
            --目标位面失衡:
            {
                CLASS = "action.QSBArgsConditionSelector",
                OPTIONS = {
                    failed_select = 1,
                    {expression = "target:is_actor_dead", select = 2},
                }
            },
            {
                CLASS = "composite.QSBSelector",
                ARGS = {   
                    {
                        CLASS = "composite.QSBParallel",
                        ARGS = 
                        { 
                            {
                                CLASS = "action.QSBHitTarget",
                                OPTIONS = {damage_scale = ds},
                            }, 
                            {
                                CLASS = "action.QSBTriggerSkill",   
                                OPTIONS = {skill_id = 301610, wait_finish = false},
                            },
                            {
                                CLASS = "action.QSBPlayEffect",
                                OPTIONS = {effect_id = "pf_ssptanghao02_attack01_3", is_hit_effect = true},
                            }, 
                        },
                    },
                },
            }, 
            
        },
    }
    return hit_node
end

local SECOND_HIT =
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation ="attack11_2",no_stand = true},
        },
        HIT_WITH_SHENJI(8,1.2),
        
        {
            CLASS = "composite.QSBSequence",
            ARGS = {

                    {
                        CLASS = "action.QSBDelayTime",
                        OPTIONS = {delay_frame = 7},
                    },

                    {
                        CLASS = "action.QSBPlayEffect",
                        OPTIONS = {effect_id = "pf_ssptanghao02_attack11_2_1", is_hit_effect = false},
                    }, 
                    {
                        CLASS = "action.QSBPlayEffect",
                        OPTIONS = {effect_id = "pf_ssptanghao02_attack11_2_2", is_hit_effect = false},
                    }, 
            },
        },

        -- {
        --     CLASS = "action.QSBPlayEffect",
        --     OPTIONS = {effect_id = "pf_ssptanghao02_attack11_2_1", is_hit_effect = false},
        -- }, 
        -- {
        --     CLASS = "action.QSBPlayEffect",
        --     OPTIONS = {effect_id = "pf_ssptanghao02_attack11_2_2", is_hit_effect = false},
        -- }, 
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 11},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_ssptanghao02_attack11_3_1", is_hit_effect = false}, --第三下锤子前摇
                }, 
            },
        },
    },
}

local THIRD_HIT =
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation ="attack11_3",no_stand = true},
        },
        HIT_WITH_SHENJI(6,1.44),
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 2},
                },  
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "pf_ssptanghao02_attack11_3_2", is_hit_effect = false},
                        }, 
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "pf_ssptanghao02_attack11_1_3_3", is_hit_effect = false},
                        }, 
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "pf_ssptanghao02_attack11_1_3_4", is_hit_effect = false},
                        }, 
                        {
                            CLASS = "action.QSBShakeScreen",
                            OPTIONS = {amplitude = 20, duration = 0.25, count = 1,},
                        },
                    },
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 23},
                }, 
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "ssptanghao_dazhao_buff", is_target = false},
                },
                {
                    CLASS = "action.QSBLockTarget",
                    OPTIONS = {is_lock_target = false, revertable = true},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

local MOVE_TO_TARGET_2 =
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBLockTarget",
                    OPTIONS = {is_lock_target = false, revertable = true},
                },
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {min_distance = true, change_all_node_target = true,not_copy_hero = true},
                },
                {
                    CLASS = "action.QSBLockTarget",
                    OPTIONS = {is_lock_target = true, revertable = true},
                },
                {
                    CLASS = "action.QSBActorFadeOut",
                    OPTIONS = {duration = 0.01, revertable = true},
                },
                {
                    CLASS = "action.QSBArgsIsDirectionLeft",
                    OPTIONS = {is_attacker = false},
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = { 
                        {
                            CLASS = "action.QSBCharge",
                            OPTIONS = {offset = {x = -150, y = 0},move_time = 0.01,fcae_target = true},
                        },
                        {
                            CLASS = "action.QSBCharge",
                            OPTIONS = {offset = {x = 150, y = 0},move_time = 0.01,fcae_target = true},
                        },
                    },
                },
                {
                    CLASS = "action.QSBActorFadeIn",
                    OPTIONS = {duration = 0.2, revertable = true},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 4},
                },
                SECOND_HIT, 
            },
        },
    },
}


local MOVE_TO_TARGET_3 =
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBLockTarget",
                    OPTIONS = {is_lock_target = false, revertable = true},
                },
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {min_distance = true, change_all_node_target = true,not_copy_hero = true},
                },
                {
                    CLASS = "action.QSBLockTarget",
                    OPTIONS = {is_lock_target = true, revertable = true},
                },
                {
                    CLASS = "action.QSBActorFadeOut",
                    OPTIONS = {duration = 0.01, revertable = true},
                },
                {
                    CLASS = "action.QSBArgsIsDirectionLeft",
                    OPTIONS = {is_attacker = false},
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = { 
                        {
                            CLASS = "action.QSBCharge",
                            OPTIONS = {offset = {x = -150, y = 0},move_time = 0.01,fcae_target = true},
                        },
                        {
                            CLASS = "action.QSBCharge",
                            OPTIONS = {offset = {x = 150, y = 0},move_time = 0.01,fcae_target = true},
                        },
                    },
                },
                {
                    CLASS = "action.QSBActorFadeIn",
                    OPTIONS = {duration = 0.2, revertable = true},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 5},
                },
                THIRD_HIT,
            },
        },
    },
}


local ssptanghao_dazhao = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},--不会打断特效
            ARGS = 
            {
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true,turn_on = true,time = 0.3,revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = true,revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 14},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = false},
                },
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true,turn_on = false,time = 0.3},
                },
            },
        },
        {--竞技场黑屏
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},--不会打断特效
            ARGS = 
            {
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true,turn_on = true,time = 0.3,revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = true,revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 14},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = false},
                },
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true,turn_on = false,time = 0.3},
                },
            },
        },
        -----------------------
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "ssptanghao_dazhao_buff", is_target = false},
        },
        {
            CLASS = "action.QSBPlaySound",
            OPTIONS = {sound_id ="pf_ssptanghao02_skill"},
        },
        {
            CLASS = "action.QSBLockTarget",
            OPTIONS = {is_lock_target = true, revertable = true},
        },
        ----------------------
        --- 第一击动作
        {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation ="attack11_1",no_stand = true},
        },
        HIT_WITH_SHENJI(16,1),
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 15},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_ssptanghao02_attack11_1_1", is_hit_effect = false},
                }, 
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_ssptanghao02_attack11_1_2", is_hit_effect = false},
                },

            },
        },
        ----------------------
        --- 第二击动作
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 33},
                },
                {
                    CLASS = "action.QSBArgsConditionSelector",
                    OPTIONS = {
                        failed_select = 3,
                        {expression = "target:is_actor_dead&self:ssptanghao_lianzhan", select = 1},
                        {expression = "target:is_actor_dead", select = 2},
                    }
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = {    
                        MOVE_TO_TARGET_2,
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBLockTarget",
                                    OPTIONS = {is_lock_target = false, revertable = true},
                                },
                                {
                                    CLASS = "action.QSBRemoveBuff",
                                    OPTIONS = {buff_id = "ssptanghao_dazhao_buff", is_target = false},
                                },
                                {
                                    CLASS = "action.QSBCancelCurrentSkill",
                                },  
                            },
                        },
                        SECOND_HIT, 
                    },
                },
            },
        },
        
        ----------------------
        --- 第三击动作  见SECOND_HIT
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 62},
                },
                {
                    CLASS = "action.QSBArgsConditionSelector",
                    OPTIONS = {
                        failed_select = 3,
                        {expression = "target:is_actor_dead&self:ssptanghao_lianzhan", select = 1},
                        {expression = "target:is_actor_dead", select = 2},
                    }
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = {    
                        MOVE_TO_TARGET_3,
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBLockTarget",
                                    OPTIONS = {is_lock_target = false, revertable = true},
                                },
                                {
                                    CLASS = "action.QSBRemoveBuff",
                                    OPTIONS = {buff_id = "ssptanghao_dazhao_buff", is_target = false},
                                },
                                {
                                    CLASS = "action.QSBCancelCurrentSkill",
                                },  
                            },
                        },
                        THIRD_HIT,
                    },
                },
            },
        },
        
    },
}

return ssptanghao_dazhao