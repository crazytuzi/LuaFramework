local npc_mantuoluoshe_dgy= {     
    CLASS = "composite.QAISelector",
    ARGS =
    {
		-- {
		-- 	CLASS = "composite.QAISequence",
		-- 	ARGS = 
		-- 	{
		-- 		{
		-- 			CLASS = "action.QAITimer",
		-- 			OPTIONS = {interval = 12,first_interval =8 },
		-- 		},
		-- 		{
		-- 			CLASS = "action.QAIAttackByStatus",
		-- 			OPTIONS = {status = "attack_order"},
		-- 		},	
		-- 		{
		-- 			CLASS = "action.QAIIgnoreHitLog",
		-- 		},
		-- 	},
		-- },
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 12,first_interval =1 },
				},
				{
                     CLASS = "action.QAIAttackAnyEnemy",
                },
				{
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50774},
                },
            },
        },
		-- {
		-- 	CLASS = "composite.QAISequence",
		-- 	ARGS = 
		-- 	{
		-- 		{
		-- 			CLASS = "action.QAITimer",
		-- 			OPTIONS = {interval = 12,first_interval =16 },
		-- 		},
		-- 		{
		-- 			CLASS = "action.QAIAcceptHitLog",
		-- 		},
		-- 	},
		-- },
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
        
return npc_mantuoluoshe_dgy