
local shengltxin_cuimoniaowang = {
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
                    OPTIONS = {skill_id = 53354}, -- BOSS的证明
                },
            },
        },
        -- {
        --     CLASS = "composite.QAISequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QAITimer",
        --             OPTIONS = {interval = 25,first_interval = 5},
        --         },
        --         {
        --             CLASS = "action.QAIUseSkill",
        --             OPTIONS = {skill_id = 53352}, -- 献祭
        --         },
        --     },
        -- },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 25,first_interval = 20},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53351}, -- 变身图腾回血
                },
            },
        },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
				{
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 30,first_interval = 30},
                },
				{
					CLASS = "action.QAIMoveLineStrip",
					OPTIONS = {target_list = {{x = 6,y = 0}}, speed = 300, relative = true},
				},
			},
		},
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 25,first_interval = 10},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53350}, -- 插图腾
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

return shengltxin_cuimoniaowang