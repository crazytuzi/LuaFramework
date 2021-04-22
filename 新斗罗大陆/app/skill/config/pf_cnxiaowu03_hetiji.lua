--成年小舞 大招
--创建人：庞圣峰
--创建时间：2018-3-13


local pf_cnxiaowu03_hetiji = {
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "attack11_1", revertable = true, reload_on_cancel = true, no_stand = true},
        },
        {
            CLASS = "action.QSBTeleportToTargetPos",
        },
        {
            CLASS = "action.QSBTrap", 
            OPTIONS = 
            { 
                trapId = "pf_cnxiaowu03_fazhen", is_attackee = true,
                args = 
                {
                    {delay_time = 0 , relative_pos = { x = 0, y = 0}} ,
                },
            },
        },
        {
            CLASS = "action.QSBPlaySound",
            OPTIONS = {sound_id ="pf_chengnianxiaowu03_skill"},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai", is_target = false},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "mianyi_suoyou_shanghai", is_target = false},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 9 / 24 * 30},
                },
                {
                    CLASS = "action.QSBImmuneCharge",
                    OPTIONS = {enter = true, revertable = true},
                },
                {
                    CLASS = "action.QSBManualMode",
                    OPTIONS = {enter = true, revertable = true},
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
                                    OPTIONS = {delay_frame = 6 / 24 * 30},
                                },
                                {
                                    CLASS = "action.QSBKillingSpree",
                                    OPTIONS = {center_as_target = true, afterimage_front_effect = "pf_chengnianxiaowu03_attack16" , afterimage_back_effect = "pf_chengnianxiaowu03_attack16_3", cancel_if_not_found = true, range = {min = 0, max = 5}, always = false, in_range = true, reset_target_on_cancel = true}
                                },
                                {
                                    CLASS = "action.QSBPlaySound",
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 12 / 24 * 30},
                                },
                                {
                                    CLASS = "action.QSBKillingSpree",
                                    OPTIONS = {center_as_target = true, afterimage_front_effect = "pf_chengnianxiaowu03_attack16_x" , afterimage_back_effect = "pf_chengnianxiaowu03_attack16_4_x", cancel_if_not_found = true, range = {min = 0, max = 5}, always = true, in_range = true, reset_target_on_cancel = true}
                                },
                                {
                                    CLASS = "action.QSBPlaySound",
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 18 / 24 * 30},
                                },
                                {
                                    CLASS = "action.QSBKillingSpree",
                                    OPTIONS = {center_as_target = true, afterimage_front_effect = "pf_chengnianxiaowu03_attack16_y" , afterimage_back_effect = "pf_chengnianxiaowu03_attack16_3_y", cancel_if_not_found = true, range = {min = 0, max = 5}, always = true, in_range = true, reset_target_on_cancel = true}
                                },
                                {
                                    CLASS = "action.QSBPlaySound",
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 24 / 24 * 30},
                                },
                                {
                                    CLASS = "action.QSBKillingSpree",
                                    OPTIONS = {center_as_target = true, afterimage_front_effect = "pf_chengnianxiaowu03_attack16_x" , afterimage_back_effect = "pf_chengnianxiaowu03_attack16_4_x", cancel_if_not_found = true, range = {min = 0, max = 5}, always = true, in_range = true, reset_target_on_cancel = true}
                                },
                                {
                                    CLASS = "action.QSBPlaySound",
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 30 / 24 * 30},
                                },
                                {
                                    CLASS = "action.QSBKillingSpree",
                                    OPTIONS = {center_as_target = true, afterimage_front_effect = "pf_chengnianxiaowu03_attack16_y" , afterimage_back_effect = "pf_chengnianxiaowu03_attack16_3_y", cancel_if_not_found = true, range = {min = 0, max = 5}, always = true, in_range = true, reset_target_on_cancel = true}
                                },
                                {
                                    CLASS = "action.QSBPlaySound",
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 36 / 24 * 30},
                                },
                                {
                                    CLASS = "action.QSBKillingSpree",
                                    OPTIONS = {center_as_target = true, afterimage_front_effect = "pf_chengnianxiaowu03_attack16" , afterimage_back_effect = "pf_chengnianxiaowu03_attack16_4", cancel_if_not_found = true, range = {min = 0, max = 5}, always = true, in_range = true, reset_target_on_cancel = true}
                                },
                                {
                                    CLASS = "action.QSBPlaySound",
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 42 / 24 * 30},
                                },
                                {
                                    CLASS = "action.QSBKillingSpree",
                                    OPTIONS = {center_as_target = true, afterimage_front_effect = "pf_chengnianxiaowu03_attack16_x" , afterimage_back_effect = "pf_chengnianxiaowu03_attack16_3", cancel_if_not_found = true, range = {min = 0, max = 5}, always = true, in_range = true, reset_target_on_cancel = true}
                                },
                                {
                                    CLASS = "action.QSBPlaySound",
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 48 / 24 * 30},
                                },
                                {
                                    CLASS = "action.QSBKillingSpree",
                                    OPTIONS = {center_as_target = true, afterimage_front_effect = "pf_chengnianxiaowu03_attack16_y" , afterimage_back_effect = "pf_chengnianxiaowu03_attack16_4", cancel_if_not_found = true, range = {min = 0, max = 5}, always = true, in_range = true, reset_target_on_cancel = true}
                                },
                                {
                                    CLASS = "action.QSBPlaySound",
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                             ARGS = {
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = {is_attackee = true},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 52 / 24 * 30, pass_key = {"pos"}},
                                },
                                {
                                  CLASS = "action.QSBCharge",
                                  OPTIONS = {move_time = 0.01}
                                },
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBActorStand",
                                            OPTIONS = {reload = true,}
                                        },
                                        {
                                            CLASS = "action.QSBImmuneCharge",
                                            OPTIONS = {enter = false},
                                        },
                                        {
                                            CLASS = "action.QSBActorFadeIn",
                                            OPTIONS = {duration = 0.25, revertable = true},
                                        },
                                    },
                                },
                                {
                                    CLASS = "action.QSBManualMode",
                                    OPTIONS = {exit = true},
                                },
                                {
                                    CLASS = "action.QSBChangeTargetToInit",
                                },
                                {
                                    CLASS = "action.QSBAttackFinish",
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
                    OPTIONS = {delay_frame = 61 / 24 * 30},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBRemoveBuff",
                            OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai", is_target = false},
                        },
                        {
                            CLASS = "action.QSBRemoveBuff",
                            OPTIONS = {buff_id = "mianyi_suoyou_shanghai", is_target = false},
                        },
                    },
                },
            },
        },
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
                    OPTIONS = {delay_frame = 14/24*30},
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
                    OPTIONS = {delay_frame = 14/24*30},
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
    },
}

return pf_cnxiaowu03_hetiji
