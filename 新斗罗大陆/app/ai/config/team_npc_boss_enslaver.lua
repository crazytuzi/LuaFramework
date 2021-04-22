
local team_npc_boss_enslaver = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
    ---------------------    奴役者    -------------------------------


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

-------------------------------  冲锋   -----------------------------

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
                    OPTIONS = {interval = 22},
                },
                {
                    CLASS = "action.QAIAcceptHitLog",  
                },
            },
        },


-------------------------      践踏   --------------------------------

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
					OPTIONS = {skill_id = 200177},
				},
            },
        },


-----------------------------------         召唤         -----------------------------------------
    
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAIHPLost",
                    OPTIONS = {hp_less_then = {0.5},only_trigger_once = false},        -- 多少血量一下触发一次,only_trigger_once是否重复触发
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 203012},          
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

return team_npc_boss_enslaver