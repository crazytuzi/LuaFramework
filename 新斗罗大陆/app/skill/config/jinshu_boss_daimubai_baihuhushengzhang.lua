
local boss_daimubai_baihuhushengzhang = 
{
     CLASS = "composite.QSBParallel",
     ARGS = 
     {
        {
            CLASS = "action.QSBPlaySound"
        },
        -- {
        --     CLASS = "action.QSBPlaySound",
        --     OPTIONS = {sound_id ="boss_daimubai_walk"},
        -- },
        {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "attack13"},
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
                    },
                },
            },
        },
        {
            CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
            OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "daimubai_hongquan"},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                -- {
                --  CLASS = "action.QSBSelectTarget",
                --  OPTIONS = {range_max = true},
                -- },
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
                                    OPTIONS = {delay_time = 3.4, pass_key = {"pos"}},
                                },
                                {
                                    CLASS = "action.QSBCharge", --移动向目标位置（不打断动画）
                                    OPTIONS = {move_time = 2 / 24,offset = {x= 150,y=0}},
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
                                    OPTIONS = {delay_time = 3.4, pass_key = {"pos"}},
                                },
                                {
                                    CLASS = "action.QSBCharge", --移动向目标位置（不打断动画）
                                    OPTIONS = {move_time = 2 / 24,offset = {x= -150,y=0}},
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
                    OPTIONS = {delay_time = 55 / 24 },
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack11"},
                            ARGS = 
                            {
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
                    },
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
                    OPTIONS = {delay_time = 84 / 24 },
                },
                {
                    CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 40, duration = 0.25, count = 2,},
                },
            },
        },
    },
}

return boss_daimubai_baihuhushengzhang