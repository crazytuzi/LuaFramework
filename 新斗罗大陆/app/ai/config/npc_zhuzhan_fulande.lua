
local npc_zhuzhan_fulande = {         -- 助战弗兰德AI
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 10,first_interval=5},
        --         },
        --         {
        --             CLASS = "action.QAIIsUsingSkill",
        --             OPTIONS = {reverse_result = true, check_skill_id = 50232},
        --         },
        --         {
        --             CLASS = "action.QAIUseSkill",
        --             OPTIONS = {skill_id = 50233},
        --         },
        --     },
        -- },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 100,first_interval=4},
                },
                {
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true, check_skill_id = 50120},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50120},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 300},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50119},
                },
                -- {
                --     CLASS = "action.QAIUseSkill",
                --     OPTIONS = {skill_id = 105110},
                -- },
            },
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
}

return npc_zhuzhan_fulande