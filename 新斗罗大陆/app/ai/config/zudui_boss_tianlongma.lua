
local zudui_boss_tianlongma = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500,first_interval=500},
                },
                {
                    CLASS = "action.QAIAttackLowestArmor",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 52130},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 15,first_interval=10},
                },
                {
                    CLASS = "action.QAIAttackLowestArmor",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 52112},
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

return zudui_boss_tianlongma