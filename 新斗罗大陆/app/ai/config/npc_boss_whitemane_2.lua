
local npc_boss_kresh = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500,first_interval=0},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 201107},
                },
            },
        },
        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAIHPLost",
        --             OPTIONS = {hp_less_then = {0.5}, only_trigger_once = true},
        --         },
        --         {
        --             CLASS = "action.QAIIsUsingSkill",
        --             OPTIONS = {check_skill_id  = 200817, reverse_result = true},
        --         },
        --         {
        --             CLASS = "action.QAIUseSkill",
        --             OPTIONS = {skill_id = 200205},
        --         },
        --     },
        -- },
        -- {
        --     CLASS = "action.QAIIsUsingSkill",
        --     OPTIONS = {check_skill_id  = 200205},
        -- },
        
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 35,first_interval=10},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200817},
                },
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

return npc_boss_kresh