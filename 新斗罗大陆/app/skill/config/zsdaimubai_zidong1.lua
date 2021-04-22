local boss_niumang_shuilao = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "action.QSBArgsIsUnderStatus",
            OPTIONS = {is_attacker = true,status = "zsdmb_bs"},
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
                            CLASS = "composite.QSBSequence",
                            ARGS =
                            {
                                {
                                    CLASS = "action.QSBPlayAnimation",
                                    OPTIONS = {animation = "attack12"},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS =
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 3 / 30 },
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = false, effect_id = "zsdaimubai_attack12_1"},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS =
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 8 / 30 },
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = false, effect_id = "zsdaimubai_attack12_1_1"},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 20 / 30 },
                                },
                                {
                                    CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 4, duration = 0.4, count = 3,},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS =
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 2 / 30 },
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = false, effect_id = "zsdaimubai_attack12_2"},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS =
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 20 / 30 },
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = false, effect_id = "zsdaimubai_attack12_3"},
                                },
                                {
                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                    OPTIONS = {interval_time = 0.1, attacker_face = true,attacker_underfoot = true,count = 1, distance = 0, trapId = "zsdaimubai_bhpms"},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS =
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 46 / 30 },
                                },
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBPlayAnimation",
                                            OPTIONS = {animation = "attack11_3"},
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
                                                            CLASS = "action.QSBArgsPosition",
                                                            OPTIONS = {is_attackee = true},
                                                        },
                                                        {
                                                            CLASS = "action.QSBDelayTime",
                                                            OPTIONS = {delay_time = 0, pass_key = {"pos"}},
                                                        },
                                                        {
                                                            CLASS = "action.QSBCharge", --移动向目标位置（不打断动画）
                                                            OPTIONS = {move_time = 10 / 30,offset = {x= -150,y=0}},
                                                        },
                                                    },
                                                },
                                                {
                                                    CLASS = "composite.QSBSequence",
                                                    ARGS = 
                                                    {
                                                        {
                                                            CLASS = "action.QSBArgsPosition",
                                                            OPTIONS = {is_attackee = true},
                                                        },
                                                        {
                                                            CLASS = "action.QSBDelayTime",
                                                            OPTIONS = {delay_time = 0, pass_key = {"pos"}},
                                                        },
                                                        {
                                                            CLASS = "action.QSBCharge", --移动向目标位置（不打断动画）
                                                            OPTIONS = {move_time = 10 / 30,offset = {x= 150,y=0}},
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
                                                    OPTIONS = {delay_time = 17 / 30 },
                                                },
                                                {
                                                    CLASS = "composite.QSBParallel",
                                                    ARGS = 
                                                    {
                                                        {
                                                            CLASS = "action.QSBShakeScreen",
                                                            OPTIONS = {amplitude = 4, duration = 0.4, count = 2,},
                                                        },
                                                        {
                                                          CLASS = "action.QSBHitTarget",
                                                        },
                                                    },
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "action.QSBPlayEffect",
                                            OPTIONS = {is_hit_effect = false, effect_id = "zsdaimubai2_attack11_3"},
                                        }, 
                                        {
                                            CLASS = "action.QSBPlayEffect",
                                            OPTIONS = {is_hit_effect = false, effect_id = "zsdaimubai2_attack11_3_1"},
                                        },   
                                    },
                                },
                            },
                        },
                    },
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
                                    CLASS = "action.QSBPlayAnimation",
                                    OPTIONS = {animation = "attack12"},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS =
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 3 / 30 },
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = false, effect_id = "zsdaimubai_attack12_1"},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS =
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 8 / 30 },
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = false, effect_id = "zsdaimubai_attack12_1_1"},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 20 / 30 },
                                },
                                {
                                    CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 4, duration = 0.4, count = 3,},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS =
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 2 / 30 },
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = false, effect_id = "zsdaimubai_attack12_2"},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS =
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 20 / 30 },
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = false, effect_id = "zsdaimubai_attack12_3"},
                                },
                                {
                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                    OPTIONS = {interval_time = 0.1, attacker_face = true,attacker_underfoot = true,count = 1, distance = 0, trapId = "zsdaimubai_bhpms"},
                                },
                            },
                        },
                    },
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return boss_niumang_shuilao