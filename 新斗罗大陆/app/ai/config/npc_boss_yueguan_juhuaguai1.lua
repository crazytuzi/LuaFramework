--boss 月关召唤的紫色菊花怪
--id 3337
--普攻ID:50193
--普攻,临死加BOSS攻5秒
--创建人：庞圣峰
--创建时间：2018-4-6

local npc_boss_yueguan_juhuaguai1 = {     
	CLASS = "composite.QAISelector",
    ARGS =
    {
		-- {
            -- CLASS = "composite.QAISequence",
            -- ARGS = 
            -- {
                -- {
                    -- CLASS = "action.QAITimer",
                    -- OPTIONS = {interval = 999,first_interval = 0},
                -- },
                -- {
                    -- CLASS = "action.QAIUseSkill",
                    -- OPTIONS = {skill_id = 50419}, -- 变紫色
				-- },
            -- },
        -- },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 999,first_interval = 10},
                },
				{
                    CLASS = "action.QAIAttackByStatus",
					OPTIONS = {is_team = true, status = "boss_special_mark"},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50421}, -- 临终加攻
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
return npc_boss_yueguan_juhuaguai1