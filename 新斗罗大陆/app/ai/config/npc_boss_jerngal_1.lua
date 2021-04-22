
local npc_boss_jerngal = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
      
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 9,first_interval = 6,relative = true},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
					OPTIONS = {distance = 5},
                },
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 200501},
				},
            },
        },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 30, first_interval = 18.5, relative = true},
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

return npc_boss_jerngal