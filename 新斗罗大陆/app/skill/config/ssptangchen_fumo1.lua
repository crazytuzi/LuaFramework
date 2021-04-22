
local pf_cnxiaowu_zidong1 = 
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
            CLASS = "action.QSBTeleportToTargetBehind",
            OPTIONS = {verify_flip = true },
        },  
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBActorFadeOut",
                    OPTIONS = {duration = 0.25, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 25 },
                },
                {
                    CLASS = "action.QSBActorFadeIn",
                    OPTIONS = {duration = 0.25, revertable = true},
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
                    OPTIONS = {sound_id ="ssptangchen__skill"},--声音
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 2},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack11_1"},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack11_2"},
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
                    OPTIONS = {delay_frame = 1},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "ssptangchen_attack11_1", is_hit_effect = false}, --大招施法
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 32},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "ssptangchen_attack11_2", is_hit_effect = false}, --大招空中蓄力
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 32},
                },
                {
                    CLASS = "action.QSBArgsConditionSelector",
                    OPTIONS = 
                    {
                        failed_select = 1,
                        {expression = "self:buff_num:ssptangchen_sj1_jt1=1", select = 2},
                        {expression = "self:buff_num:ssptangchen_sj2_jt1=1", select = 3},
                        {expression = "self:buff_num:ssptangchen_sj3_jt1=1", select = 4},
                        {expression = "self:buff_num:ssptangchen_sj4_jt1=1", select = 5},
                        {expression = "self:buff_num:ssptangchen_sj5_jt1=1", select = 6},
                    }
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
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = true, buff_id = "ssptangchen_sj0_xueyin"},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = false, buff_id = "ssptangchen_sj0_xiuluo", no_cancel = true},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = true, buff_id = "ssptangchen_fumo1_debuff"},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = true, buff_id = "ssptangchen_sj1_xueyin"},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = false, buff_id = "ssptangchen_sj1_xiuluo", no_cancel = true},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = true, buff_id = "ssptangchen_fumo1_debuff"},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = true, buff_id = "ssptangchen_sj2_xueyin"},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = false, buff_id = "ssptangchen_sj2_xiuluo", no_cancel = true},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = true, buff_id = "ssptangchen_fumo1_debuff"},
                                },
                            },
                        },                        
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = true, buff_id = "ssptangchen_sj3_fengyin"},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = true, buff_id = "ssptangchen_sj3_xueyin"},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = false, buff_id = "ssptangchen_sj3_xiuluo", no_cancel = true},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = true, buff_id = "ssptangchen_fumo1_debuff"},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = true, buff_id = "ssptangchen_sj4_fengyin"},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = true, buff_id = "ssptangchen_sj4_xueyin"},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = false, buff_id = "ssptangchen_sj4_xiuluo", no_cancel = true},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = true, buff_id = "ssptangchen_fumo1_debuff"},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = true, buff_id = "ssptangchen_sj5_fengyin"},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = true, buff_id = "ssptangchen_sj5_xueyin"},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = false, buff_id = "ssptangchen_sj5_xiuluo", no_cancel = true},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = true, buff_id = "ssptangchen_fumo1_debuff"},
                                },
                            },
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
                    OPTIONS = {delay_frame = 39},
                },
                {
                    CLASS = "action.QSBArgsConditionSelector",
                    OPTIONS = 
                    {
                        failed_select = 1,
                        {expression = "self:buff_num:ssptangchen_sj0_jt1=1", select = 1},
                        {expression = "self:buff_num:ssptangchen_sj1_jt1=1", select = 2},
                        {expression = "self:buff_num:ssptangchen_sj2_jt1=1", select = 3},
                        {expression = "self:buff_num:ssptangchen_sj3_jt1=1", select = 4},
                        {expression = "self:buff_num:ssptangchen_sj4_jt1=1", select = 5},
                        {expression = "self:buff_num:ssptangchen_sj5_jt1=1", select = 6},
                    }
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBHitTarget",
                            OPTIONS = {damage_scale = 2.05,check_target_by_skill = true},
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                            OPTIONS = {damage_scale = 2.45,check_target_by_skill = true},
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                            OPTIONS = {damage_scale = 2.55,check_target_by_skill = true},
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                            OPTIONS = {damage_scale = 2.65,check_target_by_skill = true},
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                            OPTIONS = {damage_scale = 2.75,check_target_by_skill = true},
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                            OPTIONS = {damage_scale = 2.85,check_target_by_skill = true},
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
                    OPTIONS = {delay_frame = 48},
                },
                {
                    CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 4, duration = 0.35, count = 2,},
                },
            },
        },   
    },
}

return pf_cnxiaowu_zidong1