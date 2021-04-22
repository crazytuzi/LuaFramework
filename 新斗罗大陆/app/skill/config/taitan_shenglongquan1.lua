
local taitan_shenglongquan = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true},
            ARGS = {
                {
                    CLASS = "action.QSBLockTarget",     --锁定目标
                    OPTIONS = {is_lock_target = true, revertable = true},
                },
                {
                    CLASS = "action.QSBManualMode",     --进入手动模式
                    OPTIONS = {enter = true, revertable = true},
                },
                {
                    CLASS = "action.QSBStopMove",
                },
                {
                    CLASS = "action.QSBApplyBuff",      --加速
                    OPTIONS = {buff_id = "tongyongchongfeng_buff1"},
                },
                {
                    CLASS = "action.QSBApplyBuff",      --免控
                    OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack12", is_loop = true},       
                }, 
                {
                    CLASS = "action.QSBActorKeepAnimation",
                    OPTIONS = {is_keep_animation = true}
                },
                {
                    CLASS = "action.QSBMoveToTarget",
                    OPTIONS = {is_position = true},
                },
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "2S_stun", is_target = true},--晕2s
				},
                {
                    CLASS = "action.QSBRemoveBuff",     --去除加速
                    OPTIONS = {buff_id = "tongyongchongfeng_buff1"},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                             CLASS = "composite.QSBSequence",
                             ARGS = {
                                {
                                    CLASS = "action.QSBReloadAnimation",
                                },
                                {
                                    CLASS = "action.QSBActorKeepAnimation",
                                    OPTIONS = {is_keep_animation = false}
                                },
                                {
                                    CLASS = "action.QSBActorStand",
                                },
                            },
                        },
                    },
                },
                {
                    CLASS = "action.QSBLockTarget",
                    OPTIONS = {is_lock_target = false},
                },
                {
                    CLASS = "action.QSBManualMode",
                    OPTIONS = {exit = true},
                },
            },
        },
        {
            CLASS = "action.QSBRemoveBuff",     --去除免控
            OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
        },
        {
         CLASS = "composite.QSBParallel",
         ARGS = {
                {
                    CLASS = "composite.QSBSequence",
                    OPTIONS = {forward_mode = true,},   --不会打断特效
                    ARGS = {
                        {
                            CLASS = "action.QSBShowActor",
                            OPTIONS = {is_attacker = true, turn_on = true, time = 0.3, revertable = true},
                        },
                        {
                            CLASS = "action.QSBBulletTime",
                            OPTIONS = {turn_on = true, revertable = true},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 40 / 30},
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
                            OPTIONS = {is_attacker = true, turn_on = true, time = 0.3, revertable = true},
                        },
                        {
                            CLASS = "action.QSBBulletTimeArena",
                            OPTIONS = {turn_on = true, revertable = true},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 40 / 30},
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
                    CLASS = "action.QSBPlaySound"
                },
                {
                    CLASS = "action.QSBPlaySound",
                    OPTIONS = {sound_id ="taitan_walk"},
                },
                {
                    CLASS = "composite.QSBSequence",
                     ARGS = {
                        {
                            CLASS = "action.QSBPlayAnimation",
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
                                    },
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBAttackFinish"
                        },
                    },
                },
            },
        },
    },
}

return taitan_shenglongquan