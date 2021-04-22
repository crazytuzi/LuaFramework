--斗罗AI 兽武魂BOSS 右手1阶
--宗门武魂争霸
--id 61007
--[[
宗门之壁
专属技
普攻
魂力聚焦
宗门守卫
冲击波
魂力追踪
]]--
--创建人：庞圣峰
--创建时间：2018-12-29

local zmwh_boss_shouwuhun_r1 = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500, first_interval = 0},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51366},--下标识
                },
				-- {
                    -- CLASS = "action.QAIUseSkill",
                    -- OPTIONS = {skill_id = 51335},--宗门之壁
                -- },
            },
        },
		
--------------冲击波-------------		
		-- {
            -- CLASS = "composite.QAISequence" ,
            -- ARGS = 
            -- {
                -- {
                    -- CLASS = "action.QAITimer",
                    -- OPTIONS = {interval = 19,first_interval = 42, max_hit = 2},
                -- },
				-- {
                    -- CLASS = "action.QAIIsUsingSkill",
                    -- OPTIONS = {reverse_result = true , check_skill_id = 51342},--魂力追踪
                -- }, 
                -- {
                    -- CLASS = "action.QAIUseSkill",
                    -- OPTIONS = {skill_id = 51340},--冲击波
                -- },
            -- },
        -- },
		{
            CLASS = "composite.QAISequence" ,
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 26,first_interval = 20, max_hit = 2},
                },
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 51342},
                }, 
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51340},--冲击波
                },
            },
        },
--------------------------------------------------
			
        {
			CLASS = "action.QAIAttackEnemyOutOfDistance",
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
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                },
            },
        },
    },
}

return zmwh_boss_shouwuhun_r1