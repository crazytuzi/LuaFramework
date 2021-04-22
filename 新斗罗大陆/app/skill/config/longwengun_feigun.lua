local longwengun_feigun = 
{
     CLASS = "composite.QSBSequence",
     ARGS = 
     {
        {
            CLASS = "action.QSBLockTarget",
            OPTIONS = {is_lock_target = true, revertable = true},
        },
        -- {
        --     CLASS = "action.QSBPlayEffect",
        --     OPTIONS = {effect_id = "tishi_kuang_w1_l31" , is_hit_effect = false},
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
                                    OPTIONS = {interval_time = 0.1, attacker_face = true,attacker_underfoot = true,count = 1, distance = 0, trapId = "longwengun_feigunyujing1"},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                    OPTIONS = {interval_time = 0.1, attacker_face = true,attacker_underfoot = true,count = 1, distance = 0, trapId = "longwengun_feigunyujing2"},
                                },
                            },
                        },
                    },
                },
            },
        },
        {
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_time = 18 / 24 },
        },                                             
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    ARGS = 
                    {
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {  
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
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 8 / 24 },
                        }, 
                        {
                            CLASS = "action.QSBPlaySound",
                            OPTIONS = {sound_id ="xiaowu_lxrc_sf",is_loop = true},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 40 / 24 },
                        },
                        {
                            CLASS = "action.QSBStopSound",
                            OPTIONS = {sound_id ="xiaowu_lxrc_sf"},
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
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return longwengun_feigun