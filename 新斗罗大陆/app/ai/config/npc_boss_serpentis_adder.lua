
local npc_boss_serpentis_adder = {
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
                -- {
                --     CLASS = "action.QAIHPLost",
                --     OPTIONS = {hp_less_then = {0.5},only_trigger_once = false},        -- 多少血量一下触发一次,only_trigger_once是否重复触发
                -- },
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 60,first_interval=5}, 
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 200004},          -- 召唤
                },
            },
        },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
            	{
                    CLASS = "action.QAITimeSpan",
                    OPTIONS = {from = 1, to = 9, relative = true},
                },
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 13, first_interval=7},
                },
                {
                    CLASS = "action.QAIAttackClosestEnemy",
                },
				{
                    CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 200304},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
            	{
                    CLASS = "action.QAITimeSpan",
                    OPTIONS = {from = 15, to = 23, relative = true},
                },
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 15, first_interval=6},
                },
                {
                    CLASS = "action.QAIAttackByRole",
                    OPTIONS = {role = "health"},
                },
				{
                    CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 200304},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
            	{
                    CLASS = "action.QAITimeSpan",
                    OPTIONS = {from = 33, to = 39, relative = true},
                },
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 15, first_interval=2},
                },
                {
                    CLASS = "action.QAIAttackByRole",
                    OPTIONS = {role = "dps"},
                },
				{
                    CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 200304},
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

return npc_boss_serpentis_adder