local cnxiaowu_jipao = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "action.QSBManualMode",     --进入手动模式
            OPTIONS = {enter = true, revertable = true},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack12_1"},
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = false, effect_id = "sspqianrenxue_attack05_2"},--冲锋拖尾特效
                        },
                        {
                            CLASS = "action.QSBActorFadeOut",
                            OPTIONS = {duration = 0.05, revertable = true},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.35},
                        },
                        {
                            CLASS = "action.QSBTeleportToTargetBehind",
                            OPTIONS = {verify_flip = true,is_attackee = true,is_revert = true},
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 2, duration = 0.35, count = 3,},
                                },
                                {
                                    CLASS = "action.QSBPlayAnimation",
                                    OPTIONS = {animation = "attack12_2"},
                                },
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
                                            OPTIONS = {is_hit_effect = false, effect_id = "sspqianrenxue_attack05_1"},--挥剑特效
                                        },
                                    },   
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = false, effect_id = "sspqianrenxue_attack05_3"},--前层特效
                                },
                                {
                                    CLASS = "action.QSBActorFadeIn", revertable = true,
                                    OPTIONS = {duration = 0.05},
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
                            OPTIONS = {delay_frame = 2 },
                        },
                         {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {buff_id = {"sspqianrenxue_beidong1_buff"}, is_target = false},--加双防Buff
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.7},
                        },
                        {
                          CLASS = "action.QSBHitTarget",
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.7},
                        },
                        {
                            CLASS = "action.QSBManualMode",
                            OPTIONS = {exit = true},
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

return cnxiaowu_jipao