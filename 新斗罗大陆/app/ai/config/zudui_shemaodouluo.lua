local npc_boss_yangwudi = 
{
    CLASS = "composite.QAISelector",
    ARGS = 
    {
    	{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 70, first_interval=4},
				},
				{
					CLASS = "action.QAIAttackByHitlog",
					OPTIONS = {always = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 52027},--长枪牢笼1
				},
			},
		},
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
				{
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 70, first_interval= 8},
                },
                {
                    CLASS = "action.QAIMoveLineStrip",
                    OPTIONS = {target_list = {{x = 50,y = 50}}, speed = 400},
                },
            },
        },
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 70, first_interval= 12},
				},
				{
					CLASS = "action.QAIAttackEnemyOutOfDistance",
					OPTIONS = {current_target_excluded = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 52029},--长枪牢笼2
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 70, first_interval= 16},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 52032},--UBW
				},
			},
		},
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
				{
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 70, first_interval= 22},
                },
                {
                    CLASS = "action.QAIMoveLineStrip",
                    OPTIONS = {target_list = {{x = 400,y = -300}}, speed = 400},
                },
            },
        },
        {
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 70, first_interval=25},
				},
				{
					CLASS = "action.QAIAttackByHitlog",
					OPTIONS = {always = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 52031},--长枪牢笼3
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 70, first_interval=28},
				},
				{
					CLASS = "action.QAIAttackEnemyOutOfDistance",
					OPTIONS = {current_target_excluded = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 52027},--长枪牢笼1
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 70, first_interval=37},
				},
				{
					CLASS = "action.QAIAttackByHitlog",
					OPTIONS = {always = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 52031},--长枪牢笼3
				},
			},
		},
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
				{
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 70, first_interval= 40},
                },
                {
                    CLASS = "action.QAIMoveLineStrip",
                    OPTIONS = {target_list = {{x = 0,y = -300}}, speed = 425},
                },
            },
        },
        {
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 70, first_interval=45},
				},
				{
					CLASS = "action.QAIAttackByHitlog",
					OPTIONS = {always = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 52031},--长枪牢笼3
				},
			},
		},
        {
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 70, first_interval= 48},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 52032},--UBW
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 70, first_interval=52},
				},
				{
					CLASS = "action.QAIAttackEnemyOutOfDistance",
					OPTIONS = {current_target_excluded = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 52027},--长枪牢笼1
				},
			},
		},
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
				{
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 70, first_interval= 55},
                },
                {
                    CLASS = "action.QAIMoveLineStrip",
                    OPTIONS = {target_list = {{x = 0,y = 300}}, speed = 400},
                },
            },
        },
        {
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 70, first_interval=60},
				},
				{
					CLASS = "action.QAIAttackByHitlog",
					OPTIONS = {always = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 52027},--长枪牢笼1
				},
			},
		},
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
				{
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 70, first_interval= 65},
                },
                {
                    CLASS = "action.QAIMoveLineStrip",
                    OPTIONS = {target_list = {{x = 400,y = 300}}, speed = 400},
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