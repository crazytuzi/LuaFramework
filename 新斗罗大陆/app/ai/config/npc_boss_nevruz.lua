
local variation_adder= {
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
                    OPTIONS = {interval = 180,first_interval=20},
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                },
                
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200916},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 180,first_interval=45},
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                },
                
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200917},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 180,first_interval=120},
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                },
                
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200918},
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
        
return variation_adder
