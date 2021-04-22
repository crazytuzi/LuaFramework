local cnxiaowu_jipao = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack06_1"},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        -- {
                        --     CLASS = "action.QSBActorStand",
                        -- },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = false, effect_id = "zsdaimubai_attack06_1"},
                        },
                        {
                            CLASS = "action.QSBActorFadeOut",
                            OPTIONS = {duration = 0.35, revertable = true},
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
                			OPTIONS = {verify_flip = true},
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
                                    OPTIONS = {animation = "attack06_2"},
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = false, effect_id = "zsdaimubai_attack06_2"},
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
                            OPTIONS = {delay_time = 0.7},
                        },
                        {
                          CLASS = "action.QSBHitTarget",
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.35},
                        },
                        {
                            CLASS = "action.QSBAttackFinish"
                        },
                    },
                },
            },
        },
        -- {
        --     CLASS = "action.QSBAttackFinish"
        -- },
    },
}

return cnxiaowu_jipao