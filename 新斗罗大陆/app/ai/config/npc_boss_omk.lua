
local npc_boss_omk = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
    ---------------------    欧莫克大王    ---------------------------

    ----------------------      免疫       ---------------------------

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


-------------------------      歼灭   --------------------------------

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
					OPTIONS = {skill_id = 200136},
				},
            },
        },

--------------------------     狂乱          -------------------------

        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 18,first_interval=20},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200504},
                },
            },
        },

--------------------------     恐惧       ---------------------------

        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 24,first_interval=30},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200137},
                },
            },
        },


-------------------------------  冲锋   -----------------------------

        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 25},
        --         },
        --         {
        --             CLASS = "action.QAIAttackEnemyOutOfDistance",
        --         },
        --         {
        --             CLASS = "action.QAIUseSkill",
        --             OPTIONS = {skill_id = 200321},    
        --         },
        --         {
        --             CLASS = "action.QAIIgnoreHitLog",  
        --         },
        --     },
        -- },
        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 29},
        --         },
        --         {
        --             CLASS = "action.QAIAcceptHitLog",  
        --         },
        --     },
        -- },

--------------------------------------------------------------------
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

return npc_boss_omk