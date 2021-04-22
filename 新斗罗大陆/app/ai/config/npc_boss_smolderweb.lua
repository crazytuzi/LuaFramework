
local npc_boss_smolderweb = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
       ---------------------------   免疫      --------------------------------
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
                    OPTIONS = {skill_id = 201103},
                },
            },
        },
    -- ------------------------------    冲锋   ------------------------------------------
    --       {
    --         CLASS = "composite.QAISequence",
    --         ARGS = 
    --         {
    --             {
    --                 CLASS = "action.QAITimer",
    --                 OPTIONS = {interval = 25,first_interval=8},
    --             },
    --             {
    --                 CLASS = "action.QAIAttackEnemyOutOfDistance",
    --             },
    --             {
    --                 CLASS = "action.QAIUseSkill",
    --                 OPTIONS = {skill_id = 200321},     
    --             },
    --             {
    --                 CLASS = "action.QAIIgnoreHitLog",  
    --             },
    --         },
    --     },
    --     {
    --         CLASS = "composite.QAISequence",
    --         ARGS = 
    --         {
    --             {
    --                 CLASS = "action.QAITimer",
    --                 OPTIONS = {interval = 29},
    --             },
    --             {
    --                 CLASS = "action.QAIAcceptHitLog",  
    --             },
    --         },
    --     },

    -------------------------   召唤   -----------------------------------------------
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 15,first_interval=15},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200134},    
                },
            },
        },
    -------------------------  蛛后的乳汁   ------------------------------------------

        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 15,first_interval=10},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200133},    
                },
            },
        },

    --------------------------    boss狂暴  ------------------------------------------
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500,first_interval=85},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 201107},
                },
            },
        },

        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500,first_interval=90},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200002},
                },
            },
        },

    ----------------------------------------------------------------------------------

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

return npc_boss_smolderweb