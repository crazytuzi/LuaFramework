
local gudouluo_fumo1_hetiji = {
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
                    OPTIONS = {delay_frame = 73},
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
                    OPTIONS = {delay_frame = 73},
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
                    CLASS = "action.QSBArgsPosition",
                    OPTIONS = {is_attacker = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 97, pass_key = {"pos"}},
                },
                {
                  CLASS = "action.QSBCharge",
                  OPTIONS = {move_time = 0.01}
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {lowest_hp = true, change_all_node_target = true},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack11_1"},
                },
                {
                    CLASS = "action.QSBActorFadeOut",
                    OPTIONS = {duration = 0.01, revertable = true},
                },
                {
                    CLASS = "action.QSBTeleportToTargetPos",
                    OPTIONS = {is_attackee = true},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBActorFadeIn",
                            OPTIONS = {duration = 0.01, revertable = true},
                        },
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack11_2"},
                            ARGS = {
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {  
                                        {
                                            CLASS = "action.QSBPlayEffect",
                                            OPTIONS = {is_hit_effect = true},
                                        },
                                        {
                                            CLASS = "action.QSBHitTarget",
                                        },
                                        {
                                            CLASS = "action.QSBShakeScreen",
                                        },
                                        {
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {buff_id = {"gudouluo_fumo1_p", "gudouluo_fumo1_m", "gudouluo_dazhao_cuihua;y", "gudouluo_dazhao_hetiji"}, is_target = true, no_cancel = true},
                                        },
                                        {
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {buff_id = "gudouluo_fumo1_chuandi", is_target = true, no_cancel = true},
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
                                    OPTIONS = {delay_frame = 32},
                                },
                                {
                                    CLASS = "action.QSBPlayAnimation",
                                    OPTIONS = {animation = "attack11_3"},
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
    },
}

return gudouluo_fumo1_hetiji