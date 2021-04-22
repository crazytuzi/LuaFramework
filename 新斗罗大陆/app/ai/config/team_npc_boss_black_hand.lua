
local team_npc_boss_black_hand = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
    ---------------------    雷德·黑手    ----------------------------

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


-------------------------      旋风斩   --------------------------------

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
					OPTIONS = {skill_id = 200139},
				},
            },
        },

--------------------------     狂暴          -------------------------

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
                    OPTIONS = {skill_id = 200140},
                },
            },
        },

--------------------------     召唤       ---------------------------

        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 30,first_interval=30},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200003},
                },
            },
        },


-----------------------------  冲锋   -------------------------------

        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 25},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200321},    
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
                    OPTIONS = {interval = 29},
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

return team_npc_boss_black_hand