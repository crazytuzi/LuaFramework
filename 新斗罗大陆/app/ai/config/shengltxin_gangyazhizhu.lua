local npc_gangyazhizhu = {
    CLASS = "composite.QAISelector",
    ARGS =
    {  
       {
            CLASS = "action.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAIIsHaveTarget",
                },

                {
                    CLASS = "action.QAISequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAITimer",
                            OPTIONS = {interval = 600, first_interval = 1, allow_frameskip = true},
                        },
                        {
                            CLASS = "action.QAITrackTarget",
                        },
                        {
                            CLASS = "action.QAIResult",
                            OPTIONS = {result = true},
                        },
                    },
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 240, first_interval = 1},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53375}, --免疫腐蚀
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
                    CLASS = "action.QAIAttackAnyEnemy",
                },
                {
                    CLASS = "action.QAITrackTarget",
                },
                {
                    CLASS = "action.QAIRewindTimers",
                },
            },
        },
    },
}
        
return npc_gangyazhizhu