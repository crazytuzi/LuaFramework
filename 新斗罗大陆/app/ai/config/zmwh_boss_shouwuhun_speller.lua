--斗罗AI 兽技释放者
--宗门武魂争霸
--id 61025
--[[
普攻
红圈
守卫
]]--
--创建人：庞圣峰
--创建时间：2018-12-29

local zmwh_boss_shouwuhun_speller = {
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
                    OPTIONS = {skill_id = 51364},--施法者标识
                },
            },
        },
-----------------魂力聚焦----------------
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 180, first_interval = 6, max_hit = 1},
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
									CLASS = "action.QAIAttackByStatus",
									OPTIONS = {status = "lock_up"},
								},
								{
									CLASS = "action.QAIUseSkill",
									OPTIONS = {skill_id = 51338},     --魂力聚焦
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
									OPTIONS = {skill_id = 51338},     --魂力聚焦
								},
							},
						},
					},	
				},
				{
					CLASS = "composite.QAISelector",
					ARGS = 
					{
						{
							CLASS = "action.QAIAttackByRole",
							OPTIONS = {role = "t",always = true},
						},
						{
							CLASS = "action.QAIAttackByHitlog",
						},
					},	
				},
			},
		},
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 180, first_interval = 15, max_hit = 1},
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
									CLASS = "action.QAIAttackByStatus",
									OPTIONS = {status = "lock_up"},
								},
								{
									CLASS = "action.QAIUseSkill",
									OPTIONS = {skill_id = 51338},     --魂力聚焦
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
									OPTIONS = {skill_id = 51338},     --魂力聚焦
								},
							},
						},
					},	
				},
				{
					CLASS = "composite.QAISelector",
					ARGS = 
					{
						{
							CLASS = "action.QAIAttackByRole",
							OPTIONS = {role = "t",always = true},
						},
						{
							CLASS = "action.QAIAttackByHitlog",
						},
					},	
				},
			},
		},
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 180, first_interval = 27, max_hit = 1},
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
									CLASS = "action.QAIAttackByStatus",
									OPTIONS = {status = "lock_up"},
								},
								{
									CLASS = "action.QAIUseSkill",
									OPTIONS = {skill_id = 51338},     --魂力聚焦
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
									OPTIONS = {skill_id = 51338},     --魂力聚焦
								},
							},
						},
					},	
				},
				{
					CLASS = "composite.QAISelector",
					ARGS = 
					{
						{
							CLASS = "action.QAIAttackByRole",
							OPTIONS = {role = "t",always = true},
						},
						{
							CLASS = "action.QAIAttackByHitlog",
						},
					},	
				},
			},
		},
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 44, first_interval = 39},
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
									CLASS = "action.QAIAttackByStatus",
									OPTIONS = {status = "lock_up"},
								},
								{
									CLASS = "action.QAIUseSkill",
									OPTIONS = {skill_id = 51338},     --魂力聚焦
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
									OPTIONS = {skill_id = 51338},     --魂力聚焦
								},
							},
						},
					},	
				},
				{
					CLASS = "composite.QAISelector",
					ARGS = 
					{
						{
							CLASS = "action.QAIAttackByRole",
							OPTIONS = {role = "t",always = true},
						},
						{
							CLASS = "action.QAIAttackByHitlog",
						},
					},	
				},
			},
		},
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 21, first_interval = 51},
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
									CLASS = "action.QAIAttackByStatus",
									OPTIONS = {status = "lock_up"},
								},
								{
									CLASS = "action.QAIUseSkill",
									OPTIONS = {skill_id = 51338},     --魂力聚焦
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
									OPTIONS = {skill_id = 51338},     --魂力聚焦
								},
							},
						},
					},	
				},
				{
					CLASS = "composite.QAISelector",
					ARGS = 
					{
						{
							CLASS = "action.QAIAttackByRole",
							OPTIONS = {role = "t",always = true},
						},
						{
							CLASS = "action.QAIAttackByHitlog",
						},
					},	
				},
			},
		},
--------------------------------------
-----------------宗门守卫----------------
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 22.5, first_interval = 10},
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                    OPTIONS = {always = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51339},     --宗门守卫
                },
				{
					CLASS = "composite.QAISelector",
					ARGS = 
					{
						{
							CLASS = "action.QAIAttackByRole",
							OPTIONS = {role = "t",always = true},
						},
						{
							CLASS = "action.QAIAttackByHitlog",
						},
					},	
				},
            },
        },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 180, first_interval = 66, max_hit = 2},
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                    OPTIONS = {always = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51339},     --宗门守卫
                },
				{
					CLASS = "composite.QAISelector",
					ARGS = 
					{
						{
							CLASS = "action.QAIAttackByRole",
							OPTIONS = {role = "t",always = true},
						},
						{
							CLASS = "action.QAIAttackByHitlog",
						},
					},	
				},
            },
        },
--------------------------------------------------
			
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

return zmwh_boss_shouwuhun_speller