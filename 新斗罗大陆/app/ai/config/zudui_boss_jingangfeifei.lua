
local zudui_boss_jingangfeifei = 
{
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 30,first_interval=15},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 52104},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 40,first_interval=0},
                },
                {
                    CLASS = "action.QAISequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAIAttackAnyEnemy",--随机选择目标
                        },
                        {
                            CLASS = "action.QAISequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAITimer",
                                    OPTIONS = {interval = 2, first_interval = 0.3, allow_frameskip = true},
                                },
                                {
                                    CLASS = "action.QAITrackTarget",    -- 一根筋
                                    OPTIONS = {interval = 3},
                                },
                                {
                                    CLASS = "action.QAIResult",
                                    OPTIONS = {result = true},
                                },
                            },
                        },
                    },
                },
            },
        },    
        {
            CLASS = "action.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "decorate.QAIInvert",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAIIsHaveTarget",
                        },
                    },
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",--随机选择目标
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 40,first_interval=20},
                },
                {
                    CLASS = "composite.QAISelector",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAITrackTarget",
                            OPTIONS = {disable = true},
                        },
                        {
                            CLASS = "action.QAIAttackByHitlog",
                        },
                        {
                            CLASS = "composite.QAISelector",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QAIIsAttacking",
                                },
                                {
                                    CLASS = "action.QAIBeatBack",
                                },
                                {
                                    CLASS = "action.QAIAttackClosestEnemy",
                                },
                            },
                        },
                    },
                },
            },
        },
    },
}

return zudui_boss_jingangfeifei