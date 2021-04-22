--斗罗AI 腐肉鳄鱼
--升灵台"巨兽沼泽"
--id 4140~43
--[[
    一根筋
]]--
--psf 2020-6-22

local shenglt_furoueyu = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        {
            CLASS = "action.QAISequence",
            ARGS = 
            {
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

return shenglt_furoueyu