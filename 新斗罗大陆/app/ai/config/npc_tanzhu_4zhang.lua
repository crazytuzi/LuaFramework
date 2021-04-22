local npc_tanzhu_4zhang = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 20, first_interval = 6},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 50799},
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

return npc_tanzhu_4zhang