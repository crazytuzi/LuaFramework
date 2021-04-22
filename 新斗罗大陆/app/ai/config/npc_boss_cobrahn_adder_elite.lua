
local npc_boss_cobrahn_adder = {
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
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {check_skill_id = 201103, reverse_result = true},
                },
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500,first_interval=1},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200322},
                },
            },
        },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 6, first_interval=6},
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                },
				{
                    CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 200401},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
            	{
                    CLASS = "action.QAITimeSpan",
                    OPTIONS = {from = 12, to = 21, relative = true},
                },
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 15, first_interval=2,allow_frameskip = true},
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                },
				{
                    CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 200402},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimeSpan",
                    OPTIONS = {from = 24.5, to = 29, relative = true},
                },
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 15, first_interval=2,allow_frameskip = true},
                },
                {
                    CLASS = "action.QAIAttackByRole",
                    OPTIONS = {role = "health"},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200402},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 60,first_interval=32},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {distance = 5},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200321},
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
                    OPTIONS = {interval = 60,first_interval = 35},
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
                    CLASS = "action.QAITimeSpan",
                    OPTIONS = {from = 37, to = 41, relative = true},
                },
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 15, first_interval=2,allow_frameskip = true},
                },
                {
                    CLASS = "action.QAIAttackByRole",
                    OPTIONS = {role = "health"},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200402},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimeSpan",
                    OPTIONS = {from = 49, to = 70, relative = true},
                },
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 5, first_interval=2,allow_frameskip = true},
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200402},
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

return npc_boss_cobrahn_adder