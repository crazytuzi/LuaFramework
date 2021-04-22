
local shengltxin_qingyufenghuang = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500,first_interval = 0},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50099}, -- 免疫
                },
            },
        },
        -- {
            -- CLASS = "composite.QAISequence",
            -- ARGS = 
            -- {
                -- {
                    -- CLASS = "action.QAITimer",
                    -- OPTIONS = {interval = 500,first_interval = 0},
                -- },
                -- {
                    -- CLASS = "action.QAIUseSkill",
                    -- OPTIONS = {skill_id = 53348}, -- 死后复活buff
                -- },
            -- },
        -- },

        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 20,first_interval = 20},
                },
				{
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53347}, -- 火焰冲击
                },
				{
                    CLASS = "action.QAITrackTarget",
                    -- OPTIONS = {interval = 2},
                },
            },
        },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 20,first_interval = 23},
                },
				{
                    CLASS = "action.QAITrackTarget",
                    OPTIONS = {disable = true},
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

return shengltxin_qingyufenghuang