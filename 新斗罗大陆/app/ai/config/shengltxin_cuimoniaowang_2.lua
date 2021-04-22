
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
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
				{
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 30,first_interval = 39},
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
                    OPTIONS = {interval = 20, first_interval = 30},
                },

                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53350},  -- 召唤图腾
                },
            },
        },

        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 25, first_interval = 23},
                },

                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53351},  -- 变成图腾
                },
            },
        },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
				{
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 50,first_interval = 10},
                },
				{
					CLASS = "action.QAIMoveLineStrip",
					OPTIONS = {target_list = {{x = -9,y = -5}}, speed = 300, relative = true},
				},
			},
		},
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 30,first_interval = 15},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53352}, -- 献祭
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