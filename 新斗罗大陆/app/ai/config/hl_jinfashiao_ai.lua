
local hl_jinfashiao_ai = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        -- {
            -- CLASS = "composite.QAISequence",
            -- ARGS = 
            -- {
                -- {
                    -- CLASS = "action.QAITimer",
                    -- OPTIONS = {interval = 500,first_interval= 0},
                -- },
                -- {
                    -- CLASS = "action.QAIUseSkill",
                    -- OPTIONS = {skill_id = 31001}, --普攻被动
                -- },
				-- {
                    -- CLASS = "action.QAIUseSkill",
                    -- OPTIONS = {skill_id = 31002}, --普攻被动
                -- },
            -- },
        -- },
		{
            CLASS = "action.QAIElf",
        },
        {
            CLASS = "action.QAIAttackByHatred",
               OPTIONS = {is_get_max = true},
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
return hl_jinfashiao_ai