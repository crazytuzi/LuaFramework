
local team_npc_boss_jerngal = {
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
                    OPTIONS = {interval = 8,first_interval = 6,relative = true},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
					OPTIONS = {distance = 5},
                },
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 203005},                  ---定时炸弹-----
				},
            },
        },

---------------冲锋-----------------
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 10, first_interval = 8, relative = true},
                },
				{
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
					OPTIONS = {distance = 5},
                },
				{
                    CLASS = "action.QAIIgnoreHitLog",
                },
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 200502},
				},
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 8,first_interval=12, relative = true},
                },
                {
                    CLASS = "action.QAIAcceptHitLog",
                },
            },
        },
        -- {
            -- CLASS = "composite.QAISequence",
            -- ARGS = 
            -- {
                -- {
                    -- CLASS = "action.QAITimer",
                    -- OPTIONS = {interval = 90},
        --         },
        --         {
        --             CLASS = "action.QAIUseSkill",
        --             OPTIONS = {skill_id = 200514},
        --         },
        --     },
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
    },
}

return team_npc_boss_jerngal