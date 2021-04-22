
local ultra_tranquility = {         -- 宁静，符文图腾

    CLASS = "composite.QSBParallel",
    ARGS = {
        {       -- 动作
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBPlayAnimation",
                                    OPTIONS = {animation = "attack11"},
                                },
                                {
                                    CLASS = "action.QSBAttackFinish"
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 23},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                },
                                {
                                    CLASS = "action.QSBDelayTime",      --36
                                    OPTIONS = {delay_frame = 17},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 17},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 17},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 17},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
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
                    OPTIONS = {delay_frame = 21},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "flash_Heal_3",is_hit_effect = true},     --治疗受击
                }, 
                {
                    CLASS = "action.QSBDelayTime",      --36
                    OPTIONS = {delay_frame = 17},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "flash_Heal_3",is_hit_effect = true},     --治疗受击
                },                 {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 17},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "flash_Heal_3",is_hit_effect = true},     --治疗受击
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 17},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "flash_Heal_3",is_hit_effect = true},     --治疗受击
                }, 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 15},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "flash_Heal_3",is_hit_effect = true},     --治疗受击
                },  
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.5},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "huichun_1_1"},     --左右手
                        }, 
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "huichun_1_2"},     --左右手
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
                    OPTIONS = {delay_time = 0.5},
                },
                {
                    CLASS = "action.QSBPlaySceneEffect",
                    OPTIONS = {effect_id = "peaceful_3_1", pos  = {x = 650 , y = 250}},
                },
            },
        },
        {   --黑屏
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},
            ARGS = {
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.7, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.72},
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
         {                  --竞技场黑屏
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},
            ARGS = {
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.7, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.72},
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
    },
}

return ultra_tranquility
