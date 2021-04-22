
local zudui_boss_bawanglong = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 24,first_interval=15},
                },
				{
					CLASS = "action.QAIAttackEnemyOutOfDistance",
				},
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 52182},
                },
            },
        },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 12,first_interval=8},
                },
				{
					CLASS = "action.QAIAttackEnemyOutOfDistance",
				},
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 52181},
                },
            },
        },
		{
			CLASS = "action.QAIAttackByStatus",
			OPTIONS = {status = "highest_rage"},
		},
        {
			CLASS = "action.QAIAttackClosestEnemy",
		},
    },
}

return zudui_boss_bawanglong