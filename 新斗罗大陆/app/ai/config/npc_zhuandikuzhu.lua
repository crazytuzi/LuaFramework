local npc_shouguzhujingying = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 27, first_interval=10},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 50757},
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 9, first_interval=4},
				},
				{
					CLASS = "action.QAIAttackByHitlog",
					OPTIONS = {always = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 50007},
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 27, first_interval=21},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 50784},
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 27, first_interval=29},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 50785},
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 9, first_interval=7.5},
				},
				{
					CLASS = "action.QAIAttackEnemyOutOfDistance",
					OPTIONS = {always = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 50382},--闪电陷阱
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

return npc_shouguzhujingying