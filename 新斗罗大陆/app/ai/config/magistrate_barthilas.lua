
local npc_boss_shade_eranikus= {
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
                    OPTIONS = {skill_id = 201103},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 25,first_interval=7},
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                    OPTIONS = {always = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 202207},
                },
            },
        },
   
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAIHealthSpan",
                    OPTIONS = {from = 1,to =0.5},               
                },
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 45,first_interval=15},
                },

                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200003},
                },
            },
        },

        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAIHealthSpan",
                    OPTIONS = {from = 0.5,to =0},               
                },
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 45,first_interval=15},
                },

                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200004},
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
	}
}
        
return npc_boss_shade_eranikus
