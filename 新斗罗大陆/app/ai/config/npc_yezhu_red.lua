 
 local npc_yezhu_red = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 8, first_interval=6},
                },
				{
	                CLASS = "action.QAIAttackAnyEnemy",
	                OPTIONS = {always = true},
	            },
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 55001},
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

return npc_yezhu_red