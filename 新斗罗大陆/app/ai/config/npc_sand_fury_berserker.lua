
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
                    OPTIONS = {interval = 10,first_interval=0.5},
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                },
                
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200921},
                },
            },
        },
	}
}
        
return variation_adder
