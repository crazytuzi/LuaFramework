--斗罗AI 深渊玳瑁
--升灵台"巨兽沼泽"
--id 4132~35
--[[
    死亡旋转
]]--
--psf 2020-6-22

local shenglt_shenyuandaimao = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500,first_interval=0},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53332},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 20,first_interval=5},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53331},
                },
            },
        },
        {
            CLASS = "action.QAISequence",
            ARGS = 
            {
                {
					CLASS = "action.QAIIsUsingSkill",
					OPTIONS = {check_skill_id = 53331},
				}, 
                {
                    CLASS = "action.QAIIsHaveTarget",
                },
                {
                    CLASS = "action.QAISequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAITimer",
                            OPTIONS = {interval = 6, first_interval = 4, allow_frameskip = true},
                        },
                        -- {
                        --     CLASS = "action.QAITrackTarget",
                        -- },
                        {
                            CLASS = "action.QAIResult",
                            OPTIONS = {result = true},
                        },
                    },
                },
            },
        },
        {
            CLASS = "action.QAISequence",
            ARGS = 
            {
                {
					CLASS = "action.QAIIsUsingSkill",
					OPTIONS = {check_skill_id = 53331},
				}, 
                {
                    CLASS = "decorate.QAIInvert",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAIIsHaveTarget",
                        },
                    },
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                },
                -- {
                --     CLASS = "action.QAITrackTarget",
                -- },
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

return shenglt_shenyuandaimao