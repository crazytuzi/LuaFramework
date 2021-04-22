
local npc_boss_wyrmthalak = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
    ---------------------    维姆萨拉克    -------------------------------

    ----------------------      免疫       -------------------------------

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
                    OPTIONS = {skill_id = 201108},
                },
            },
        },


-------------------------      如来神拳   ---------------------------------

		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 12,first_interval=8},
                },
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 200176},
				},
            },
        },


--------------------------     召唤-2小怪       ---------------------------

        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 60,first_interval=30},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200003},
                },
            },
        },


-----------------------------  火球术   -------------------------------

        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 18},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200129},    
                },
                {
                    CLASS = "action.QAIIgnoreHitLog",  
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 22},
                },
                {
                    CLASS = "action.QAIAcceptHitLog",  
                },
            },
        },

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

return npc_boss_wyrmthalak