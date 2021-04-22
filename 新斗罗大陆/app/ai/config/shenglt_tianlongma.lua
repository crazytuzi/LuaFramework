--斗罗AI：天龙马
--升灵台
--id 4108
--[[
AOE
召唤小天使
]]
--psf 2020-4-14

local shenglt_tianlongma = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 6,first_interval=2},
                },
                {
                    CLASS = "action.QAIAttackLowestArmor",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53293},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 30,first_interval= 20},
                },
                {
                    CLASS = "action.QAITeleport",
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

return shenglt_tianlongma