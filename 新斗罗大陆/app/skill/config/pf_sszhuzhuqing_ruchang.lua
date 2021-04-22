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
                            OPTIONS = {delay_time = 3 / 30 },
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
                                    OPTIONS = {is_hit_effect = false, effect_id = "pf_sszhuzhuqing_ruchang1"},
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = false, effect_id = "pf_sszhuzhuqing_ruchang2"},
                                },
                                {
                                    CLASS = "action.QSBPlayAnimation",
                                    OPTIONS = {animation = "attack21"},
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

return cnxiaowu_jipao