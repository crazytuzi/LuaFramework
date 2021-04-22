local cnxiaowu_jipao = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "action.QSBActorFadeOut",
            OPTIONS = {duration = 0.01, revertable = true},
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
                            CLASS = "action.QSBArgsPosition",
                            OPTIONS = {is_attacker = true , enter_stop_position = true},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 2 / 30 ,pass_key = {"pos"}},
                        },
                        {
                            CLASS = "action.QSBTeleportToAbsolutePosition",
                            -- OPTIONS = {pos = {x = 500, y = 320}},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 1 / 30 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBActorFadeIn",
                                    OPTIONS = {duration = 0.01, revertable = true},
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = false, effect_id = "pf02_ssqianshitangsan_attack21"},
                                },
                                {
                                    CLASS = "action.QSBPlayAnimation",
                                    OPTIONS = {animation = "attack21"},
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 10 / 30 },
                        },
                        {
                            CLASS = "action.QSBAttackFinish"
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0 / 30 },
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {is_target = false, buff_id = "sszhuzhuqing_mianyi"},
                        },
                    },
                },
            },
        },
    },
}

return cnxiaowu_jipao