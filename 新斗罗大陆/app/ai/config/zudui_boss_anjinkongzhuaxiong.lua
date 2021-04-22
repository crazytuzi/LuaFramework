
local zudui_boss_anjinkongzhuaxiong = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                CLASS = "action.QAITimer",
                    OPTIONS = {interval = 10,first_interval= 5},
                },
                {
                    CLASS = "action.QAIAttackByStatus",
                    OPTIONS = {status = "shield"},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 52106},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                CLASS = "action.QAITimer",
                    OPTIONS = {interval = 20,first_interval= 20},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 52106},
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                CLASS = "action.QAITimer",
                    OPTIONS = {interval = 20,first_interval= 10},
                },
                {
                    CLASS = "action.QAIAttackLowHp",
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

return zudui_boss_anjinkongzhuaxiong