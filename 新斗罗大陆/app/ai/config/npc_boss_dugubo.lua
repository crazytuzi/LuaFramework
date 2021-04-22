 --独孤博BOSS.psf.171228
local npc_boss_dugubo = {        
    CLASS = "composite.QAISelector",
    ARGS = 
    {
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 8, first_interval=5},
				},
				{
					CLASS = "action.QAIAttackByHatred",
					OPTIONS = {is_get_max = false},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 50128}, -- 毒沼
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 16, first_interval=16},
				},
				{
					CLASS = "action.QAIAttackByHitlog",
					OPTIONS = {always = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 50130}, -- 石化
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAIHealthSpan",
					OPTIONS = {from = 0.6},
				},
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 16, first_interval=11},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 50129}, -- 蛇影
				},
			}
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

return npc_boss_dugubo