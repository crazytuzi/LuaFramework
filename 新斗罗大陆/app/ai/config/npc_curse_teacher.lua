
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
                    OPTIONS = {interval = 180,first_interval=8},
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                },
                
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200905},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 180,first_interval=18},
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                },
                
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200905},
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
