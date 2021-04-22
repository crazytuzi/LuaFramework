
local npc_boss_jedwin_vancleef = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500,first_interval=0},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 201103},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 16,first_interval=16},
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
					OPTIONS = {always = true},
                },
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 200508},
				},
            },
        },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 16,first_interval=6},
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                    OPTIONS = {always = true},
                },
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 200510},
				},
                {
                    CLASS = "action.QAIIgnoreHitLog",
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 16,first_interval=9},
                },
                {
                    CLASS = "action.QAIAcceptHitLog",
                },
            },
        },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 16,first_interval=8},
                },
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 200511},
				},
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 12,first_interval=46},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200511},
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

return npc_boss_jedwin_vancleef