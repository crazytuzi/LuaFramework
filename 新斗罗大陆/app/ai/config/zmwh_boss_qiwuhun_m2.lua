--斗罗AI 器武魂BOSS 主体2阶
--宗门武魂争霸
--id 61011
--[[
宗门之壁
专属技
普攻
魂力聚焦
宗门守卫
冲击波
回字封锁
魂力追踪
禁锢
]]--
--创建人：庞圣峰
--创建时间：2018-12-29

local zmwh_boss_qiwuhun_m2 = {
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
                    OPTIONS = {skill_id = 51334},--BOSS标识
                },
				{
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51335},--宗门之壁
                },
            },
        },
		
--------------专属技-------------		
		{
            CLASS = "composite.QAISequence" ,
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 34,first_interval = 3, max_hit = 2},
                },
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 51345},--大招
                }, 
                -- {
                    -- CLASS = "action.QAIUseSkill",
                    -- OPTIONS = {skill_id = 51336},--专属技
                -- },
				{
                    CLASS = "action.QAIUnionDragonSpecialSkill",
                },
            },
        },
		{
            CLASS = "composite.QAISequence" ,
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 71,first_interval = 16, max_hit = 2},
                },
				{
                    CLASS = "action.QAIIsUsingSkill",
                    OPTIONS = {reverse_result = true , check_skill_id = 51345},--大招
                }, 
                -- {
                    -- CLASS = "action.QAIUseSkill",
                    -- OPTIONS = {skill_id = 51336},--专属技
                -- },
				{
                    CLASS = "action.QAIUnionDragonSpecialSkill",
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
--------------禁锢-----------------------
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 63, first_interval = 12, max_hit = 2},
                },
				{
					CLASS = "composite.QAISelector",
					ARGS = 
					{
						{
							CLASS = "composite.QAISequence",
							ARGS = 
							{
								{
									CLASS = "action.QAIAttackByRole",
									OPTIONS = {role = "t",always = true},
								},
								{
									CLASS = "action.QAIUseSkill",
									OPTIONS = {skill_id = 51350},     --禁锢
								},
							},
						},
						{
							CLASS = "composite.QAISequence",
							ARGS = 
							{
								{
									CLASS = "action.QAIAttackAnyEnemy",
									OPTIONS = {always = true},
								},
								{
									CLASS = "action.QAIUseSkill",
									OPTIONS = {skill_id = 51350},     --禁锢
								},
							},
						},
					},	
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

return zmwh_boss_qiwuhun_m2