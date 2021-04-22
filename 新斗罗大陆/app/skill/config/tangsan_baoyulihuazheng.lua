
local tangsan_baoyulihuazheng = {
     CLASS = "composite.QSBParallel",
     ARGS = {
        {
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},   --不会打断特效
            ARGS = {
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.1, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.4},
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
        {               --竞技场黑屏
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},   --不会打断特效
            ARGS = {
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.1, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.4},
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
            CLASS = "action.QSBPlaySound",
            OPTIONS = {sound_id ="tangsan_skill"},
        },
        {
            CLASS = "action.QSBPlaySound",
            OPTIONS = {revertable = true,},
        },
        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = {
        --         {
        --             CLASS = "action.QSBHitTarget",
        --         },
        --         {
        --             CLASS = "action.QSBHitTarget",
        --         },
        --         {
        --             CLASS = "action.QSBHitTarget",
        --         },
        --         {
        --             CLASS = "action.QSBHitTarget",
        --         },
        --         {
        --             CLASS = "action.QSBHitTarget",
        --         },        
        --     },
        -- },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack11_1"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {is_target = true, buff_id = "baoyulihuazhen_debuff"},
                },
                {
                    CLASS = "composite.QSBParallel",
                    OPTIONS = {pass_key = {"pos"}},
                    ARGS = {
                        {
                            CLASS = "action.QSBTeleportToTargetPos",
                            OPTIONS = {pass_key = {"pos"}},
                        },
                        {
                            CLASS = "action.QSBPlaySound",
                            OPTIONS = {sound_id ="tangsan_bylhz_zd"},
                        },
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack11_2"},
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame =  6 / 24 * 30},
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = false, effect_id = "tangsan_attack11_3"},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame =  6 / 24 * 30},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame =  2 / 24 * 30},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame =  1 / 24 * 30},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame =  1 / 24 * 30},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame =  1 / 24 * 30},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame =  6 / 24 * 30},
                                },
                                {
                                    CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 15, duration = 0.05, count = 1,},
                                },
                                {
                                    CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 15, duration = 0.1, count = 1,},
                                },
                                {
                                    CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 15, duration = 0.1, count = 1,},
                                },
                                {
                                    CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 10, duration = 0.2, count = 1,},
                                },
                                {
                                    CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 10, duration = 0.2, count = 2,},
                                },
                            },
                        },
                    },
                },
                {
                    CLASS = "action.QSBTeleportToAbsolutePosition",
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return tangsan_baoyulihuazheng

