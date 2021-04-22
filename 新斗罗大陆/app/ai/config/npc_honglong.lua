 
 local npc_honglong = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
		{
			CLASS = "action.QAIAttackByHitlog",
		},

		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 8, first_interval=6},
                },
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 55002},
				},
            },
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

return npc_honglong