local longwengun_zadi = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_hit_effect = false},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                -- {
                --     CLASS = "action.QSBPlayEffect",
                --     OPTIONS = {effect_id = "bingfengyujing" , is_hit_effect = false},
                -- },
                {
                    CLASS = "composite.QSBSequence",
                    OPTIONS = {forward_mode = true},
                    ARGS = 
                    {
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
                                            CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                            OPTIONS = {interval_time = 0.1, attacker_face = true,attacker_underfoot = true,count = 1, distance = 0, trapId = "longwengun_zadiyujing"},
                                        },
                                    },
                                },
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                            OPTIONS = {interval_time = 0.1, attacker_face = true,attacker_underfoot = true,count = 1, distance = 0, trapId = "longwengun_zadiyujing2"},
                                        },
                                    },
                                },
                            },
                        },
                    },
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 36 / 24 },
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlaySound",
                        },
                        {
                            CLASS = "action.QSBPlayAnimation",
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 15 / 24 },
                                },
                                {
                                    CLASS = "action.QSBPlaySound",
                                    OPTIONS = {sound_id ="taitan_pg2_sf"},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 15 / 24 },
                                },
                                {   
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = {is_attacker = true},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 15 / 24 },
                                },
                                {   
                                    CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 14, duration = 0.17, count = 2},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                },
                                {
                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                    OPTIONS = {interval_time = 0.1, attacker_face = false,attacker_underfoot = true,count = 4, distance = 250, trapId = "longwengun_zadi_xianjing"},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 1, pass_key = {"pos"}},
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

return longwengun_zadi