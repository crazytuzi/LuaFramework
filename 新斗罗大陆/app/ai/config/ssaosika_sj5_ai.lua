local npc_boss_yangwudi = 
{
	CLASS = "composite.QAISelector", 
	ARGS = 
	{
		{
            CLASS = "action.QAIAttackBoss"
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "decorate.QAIInvert",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAIIsHaveTarget",
                        },
                    },
                },
                {
                    CLASS = "action.QAIAttackByHitlog",
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 16, first_interval=1.75},
                },
                {
                    CLASS = "action.QAIAssassinPickTarget",
                    OPTIONS = 
                    {target_order = 
                        {
                            {actor_id = 1012, order = {4,3,2,1}},--柳二龙
                            {actor_id = 1025, order = {4,3,2,1}},--小舞
                            {actor_id = 1031, order = {4,3,2,1}},--白沉香
                            {actor_id = 1033, order = {4,3,2,1}},--朱竹清
                            {actor_id = 1049, order = {4,3,2,1}},--灵猫朱竹清
                        }
                    },
                }, 
            	{
                    CLASS = "action.QAIIsHaveTarget",
                },
                {
                    CLASS = "action.QAIUseSkillForType",
                    OPTIONS = {type = "charge_skill"},
                },
            },
        },  
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 16, first_interval=2.5},
				},
                {
                    CLASS = "action.QAIAssassinPickTarget",
                    OPTIONS = 
                    {target_order = 
                        {
                            {actor_id = 1012, order = {4,3,2,1}},--柳二龙
                            {actor_id = 1025, order = {4,3,2,1}},--小舞
                            {actor_id = 1031, order = {4,3,2,1}},--白沉香
                            {actor_id = 1033, order = {4,3,2,1}},--朱竹清
                            {actor_id = 1049, order = {4,3,2,1}},--灵猫朱竹清
                        }
                    },
                }, 
				{
				    CLASS = "action.QAIUseSkillForType",
				    OPTIONS = {type = "god_skill"},
				},
			},
		},	
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 16, first_interval=4},
				},
                {
                    CLASS = "action.QAIAssassinPickTarget",
                    OPTIONS = 
                    {target_order = 
                        {
                            {actor_id = 1012, order = {4,3,2,1}},--柳二龙
                            {actor_id = 1025, order = {4,3,2,1}},--小舞
                            {actor_id = 1031, order = {4,3,2,1}},--白沉香
                            {actor_id = 1033, order = {4,3,2,1}},--朱竹清
                            {actor_id = 1049, order = {4,3,2,1}},--灵猫朱竹清
                        }
                    },
                }, 
				{
				    CLASS = "action.QAIUseSkillForType",
				    OPTIONS = {type = "manual_skill"},
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

return npc_boss_yangwudi