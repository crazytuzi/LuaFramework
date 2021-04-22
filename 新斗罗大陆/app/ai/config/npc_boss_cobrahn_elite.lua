
local npc_boss_cobrahn = {
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
                    OPTIONS = {check_skill_id = 200302, reverse_result = true}
                },
                {
                    CLASS = "action.QAIHPLost",
                    OPTIONS = {hp_less_then = {0.5}},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200403},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimeSpan",
                    OPTIONS = {from = 7.7, to = 13, relative = true},
                },
				{
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval  = 1.5, first_interval = 2.5,allow_frameskip = true},
                },
                {
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {check_skill_id = 200403, reverse_result = true}
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200302},
                },
				{
					CLASS = "action.QAIAlwaysSuccess",
				},
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval  = 60, first_interval = 4,allow_frameskip = true},
                },
                {
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {check_skill_id = 200403, reverse_result = true}
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200302},
                },
                {
                    CLASS = "action.QAIAlwaysSuccess",
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval  = 60, first_interval = 18,allow_frameskip = true},
                },
                {
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {check_skill_id = 200403, reverse_result = true}
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200302},
                },
                {
                    CLASS = "action.QAIAlwaysSuccess",
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval  = 6, first_interval = 34,allow_frameskip = true},
                },
                {
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {check_skill_id = 200403, reverse_result = true}
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200302},
                },
                {
                    CLASS = "action.QAIAlwaysSuccess",
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimeSpan",
                    OPTIONS = {from = 24.7, to = 30, relative = true},
                },
				{
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval  = 1.5, first_interval = 2.5,allow_frameskip = true},
                },
                {
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {check_skill_id = 200403, reverse_result = true}
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200302},
                },
				{
					CLASS = "action.QAIAlwaysSuccess",
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

return npc_boss_cobrahn