local npc_anyenemy = {
    CLASS = "composite.QAISelector",
    ARGS = 
    { 
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                -- {
                --     {
                --         CLASS = "action.QAITimer",
                --         OPTIONS = {interval = 500,first_interval = 5},
                --     },
                --     {
                --         CLASS = "action.QAIUseSkill",
                --         OPTIONS = {skill_id = 50754},
                --     },
                -- },
                {
                    CLASS = "action.QAIIsAttacking",
                },
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 1.5},
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                    OPTIONS = {always = true},
                },
            },
        },
        {
            CLASS = "composite.QAISelector",
            ARGS = 
            {
                {
                    CLASS = "action.QAIIsHaveTarget",
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                }
            },
        },
    },
}
        
return npc_anyenemy