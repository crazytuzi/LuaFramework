--斗罗AI 器武魂BOSS 左手2阶
--宗门武魂争霸
--id 61014
--[[
宗门之壁
专属技
普攻
魂力聚焦
宗门守卫
冲击波
回字封锁
魂力追踪
延爆
]]--
--创建人：庞圣峰
--创建时间：2018-12-29

local zmwh_boss_qiwuhun_l2 = {
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
                    OPTIONS = {skill_id = 51366},--下标识（命名和兽武魂反了）
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
                    -- OPTIONS = {interval = 23,first_interval = 31, max_hit = 2},
                -- },
				-- {
                    -- CLASS = "action.QAIIsUsingSkill",
                    -- OPTIONS = {reverse_result = true , check_skill_id = 51352},--魂力追踪
                -- }, 
                -- {
                    -- CLASS = "action.QAIUseSkill",
                    -- OPTIONS = {skill_id = 51347},--冲击波
                -- },
            -- },
        -- },
		{
            CLASS = "composite.QAISequence" ,
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 15,first_interval = 20, max_hit = 3},
                },
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 51405},
                }, 
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51347},--冲击波
                },
            },
        },
--------------回字封锁-----------------------
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 180, first_interval = 64},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51348},     --回字封锁
                },
            },
        },
--------------弱化延爆-----------------------
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 38, first_interval = 42, max_hit = 2},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51349},     --弱化延爆
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

return zmwh_boss_qiwuhun_l2