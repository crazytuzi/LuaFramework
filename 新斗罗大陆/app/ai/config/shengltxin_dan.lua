
local shengltxin_dan = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
				{
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500,first_interval = 0},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53359}, -- 
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

return shengltxin_dan